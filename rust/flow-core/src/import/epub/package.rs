//! `container.xml`, the OPF package document and `encryption.xml`.
use super::path::resolve;
use super::xml::{attr, collapse, end_name, event_text, name, reader};
use quick_xml::events::Event;
use std::collections::HashMap;

/// A manifest entry; `path` is resolved against the OPF (`None`: escapes the archive).
#[derive(Debug)]
pub(super) struct Item {
    pub path: Option<String>,
    pub media_type: String,
    pub properties: String,
}

impl Item {
    pub fn has_property(&self, p: &str) -> bool {
        self.properties.split_whitespace().any(|t| t == p)
    }
}

/// What the package document says about the book.
#[derive(Debug, Default)]
pub(super) struct Package {
    pub title: String,
    pub authors: Vec<String>,
    pub language: Option<String>,
    pub manifest: HashMap<String, Item>,
    /// Manifest ids in document order (for deterministic scans).
    pub order: Vec<String>,
    pub spine: Vec<String>,
    pub spine_toc: Option<String>,
    cover_meta: Option<String>,
}

impl Package {
    /// Manifest id of the cover image, if any.
    pub fn cover_id(&self) -> Option<&str> {
        let is_img = |i: &Item| i.media_type.starts_with("image/");
        self.order
            .iter()
            .find(|id| {
                self.manifest
                    .get(*id)
                    .is_some_and(|i| i.has_property("cover-image") && is_img(i))
            })
            .or_else(|| {
                self.cover_meta
                    .as_ref()
                    .filter(|id| self.manifest.get(*id).is_some_and(is_img))
            })
            .map(String::as_str)
    }
}

/// Path of the package document named by `container.xml`.
pub(super) fn parse_container(xml: &str) -> Option<String> {
    let mut r = reader(xml, false);
    let mut first = None;
    loop {
        match r.read_event().ok()? {
            Event::Start(e) | Event::Empty(e) if name(&e) == "rootfile" => {
                let Some(path) = attr(&e, "full-path") else {
                    continue;
                };
                if attr(&e, "media-type").is_none_or(|m| m == "application/oebps-package+xml") {
                    return Some(path);
                }
                first.get_or_insert(path);
            }
            Event::Eof => return first,
            _ => {}
        }
    }
}

enum Capture {
    Title,
    Language,
    Creator {
        id: Option<String>,
        role: Option<String>,
    },
    Role {
        target: String,
    },
}

/// Parses the OPF; the error is the XML failure text.
pub(super) fn parse_opf(xml: &str, opf_path: &str) -> Result<Package, String> {
    let mut r = reader(xml, true);
    let mut p = Package::default();
    let mut title_seen = false;
    let mut cap: Option<(Capture, String, String)> = None; // kind, element, text
    let mut creators: Vec<(String, Option<String>, Option<String>)> = Vec::new();
    let mut roles: HashMap<String, String> = HashMap::new();
    loop {
        let ev = r.read_event().map_err(|e| e.to_string())?;
        if let (Some((_, _, buf)), Some(t)) = (cap.as_mut(), event_text(&ev)) {
            buf.push_str(&t);
            continue;
        }
        let (start, empty) = match &ev {
            Event::Start(e) => (Some(e), false),
            Event::Empty(e) => (Some(e), true),
            _ => (None, false),
        };
        if let Some(e) = start {
            let n = name(e);
            let kind = match n.as_str() {
                "title" if !title_seen => {
                    title_seen = true;
                    Some(Capture::Title)
                }
                "language" => Some(Capture::Language),
                "creator" => Some(Capture::Creator {
                    id: attr(e, "id"),
                    role: attr(e, "role"),
                }),
                "meta" => {
                    if attr(e, "name").as_deref() == Some("cover") {
                        p.cover_meta = attr(e, "content");
                    }
                    match (attr(e, "refines"), attr(e, "property")) {
                        (Some(t), Some(prop)) if prop == "role" => Some(Capture::Role {
                            target: t.trim_start_matches('#').to_owned(),
                        }),
                        _ => None,
                    }
                }
                "item" => {
                    if let Some(id) = attr(e, "id") {
                        let item = Item {
                            path: attr(e, "href")
                                .and_then(|h| resolve(opf_path, &h))
                                .map(|t| t.path),
                            media_type: attr(e, "media-type").unwrap_or_default(),
                            properties: attr(e, "properties").unwrap_or_default(),
                        };
                        if !p.manifest.contains_key(&id) {
                            p.order.push(id.clone());
                            p.manifest.insert(id, item);
                        }
                    }
                    None
                }
                "itemref" => {
                    p.spine.extend(attr(e, "idref"));
                    None
                }
                "spine" => {
                    p.spine_toc = attr(e, "toc");
                    None
                }
                _ => None,
            };
            if let Some(k) = kind {
                cap = Some((k, n, String::new()));
            }
        }
        let ended = match &ev {
            Event::End(e) => Some(end_name(e)),
            _ if empty => start.map(name),
            _ => None,
        };
        if let (Some(en), Some((_, cn, _))) = (ended, cap.as_ref()) {
            if &en == cn {
                if let Some((kind, _, buf)) = cap.take() {
                    let text = collapse(&buf);
                    match kind {
                        Capture::Title => p.title = text,
                        Capture::Language => {
                            if p.language.is_none() && !text.is_empty() {
                                p.language = Some(text);
                            }
                        }
                        Capture::Creator { id, role } => creators.push((text, id, role)),
                        Capture::Role { target } => {
                            roles.entry(target).or_insert(text);
                        }
                    }
                }
            }
        }
        if matches!(ev, Event::Eof) {
            break;
        }
    }
    for (text, id, role) in creators {
        let role = role.or_else(|| id.and_then(|i| roles.get(&i).cloned()));
        let is_author = role.is_none_or(|r| r.trim().eq_ignore_ascii_case("aut"));
        if is_author && !text.is_empty() && !p.authors.contains(&text) {
            p.authors.push(text);
        }
    }
    Ok(p)
}

const FONT_OBFUSCATION: [&str; 2] = [
    "http://www.idpf.org/2008/embedding",
    "http://ns.adobe.com/pdf/enc#RC",
];

/// Archive paths listed in `encryption.xml` with a real (non-font-obfuscation) cipher.
pub(super) fn encrypted_paths(xml: &str) -> Vec<String> {
    let mut r = reader(xml, false);
    let mut out = Vec::new();
    let mut font = false;
    while let Ok(ev) = r.read_event() {
        match ev {
            Event::Start(e) | Event::Empty(e) => match name(&e).as_str() {
                "encrypteddata" => font = false,
                "encryptionmethod" => {
                    font = attr(&e, "Algorithm")
                        .is_some_and(|a| FONT_OBFUSCATION.contains(&a.as_str()));
                }
                "cipherreference" if !font => {
                    out.extend(
                        attr(&e, "URI")
                            .and_then(|u| resolve("", &u))
                            .map(|t| t.path),
                    );
                }
                _ => {}
            },
            Event::Eof => break,
            _ => {}
        }
    }
    out
}
