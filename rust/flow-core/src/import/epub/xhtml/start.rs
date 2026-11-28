//! Start tags: which element becomes which frame, block or inline.

use super::*;
use crate::import::epub::path::resolve;
use crate::import::epub::xml::has_token;

/// `Quote` / `Footnote` containers nest as blocks in the model; the CBOR codec
/// refuses books nested ~100 levels deep, so containers stop well before that.
const MAX_CONTAINER_DEPTH: usize = 32;

pub(super) const VOID: [&str; 12] = [
    "br", "img", "hr", "meta", "link", "input", "col", "wbr", "area", "base", "source", "embed",
];
pub(super) const SKIP: [&str; 8] = [
    "head", "script", "style", "template", "rt", "rp", "object", "noscript",
];
pub(super) const BLOCKISH: [&str; 24] = [
    "p", "div", "section", "article", "aside", "nav", "header", "footer", "main", "body", "html",
    "dl", "dt", "dd", "address", "form", "fieldset", "center", "details", "summary", "hgroup",
    "caption", "thead", "tfoot",
];
pub(super) const NOTE_TYPES: [&str; 5] = [
    "footnote",
    "endnote",
    "rearnote",
    "doc-footnote",
    "doc-endnote",
];

pub(super) fn scheme_of(href: &str) -> Option<&str> {
    let (s, _) = href.split_once(':')?;
    let ok = !s.is_empty()
        && s.chars()
            .all(|c| c.is_ascii_alphanumeric() || matches!(c, '+' | '-' | '.'));
    ok.then_some(s)
}

impl Builder<'_> {
    pub(super) fn kind_for(&mut self, n: &str, e: &BytesStart<'_>) -> Kind {
        if SKIP.contains(&n) {
            return Kind::Skip;
        }
        if matches!(n, "aside" | "div" | "section" | "li" | "p") && self.footnote_start(e) {
            return Kind::Footnote;
        }
        if let Some(kind) = self.mono_kind(n, e) {
            return kind;
        }
        match n {
            "svg" => Kind::Svg,
            "b" | "strong" => Kind::Bold,
            "i" | "em" | "cite" | "dfn" | "var" => Kind::Italic,
            "code" | "tt" | "kbd" | "samp" => Kind::Code,
            "sup" => Kind::Sup,
            "sub" => Kind::Sub,
            "a" => self.link_start(e),
            "h1" | "h2" | "h3" | "h4" | "h5" | "h6" => self.heading_start(n),
            "ul" | "ol" => self.list_start(n == "ol", e),
            "li" => self.li_start(),
            "blockquote" if self.containers.len() < MAX_CONTAINER_DEPTH => {
                self.flush();
                self.containers.push(Container {
                    kind: ContainerKind::Quote,
                    blocks: Vec::new(),
                });
                Kind::Quote
            }
            "pre" if self.pre.is_none() => {
                self.flush();
                self.pre = Some(String::new());
                Kind::Pre
            }
            "table" => self.table_start(),
            "tr" | "td" | "th" => self.cell_start(n),
            "figure" if self.fig.is_none() => {
                self.flush();
                self.fig = Some(Figure::default());
                Kind::Figure
            }
            "figcaption" if self.fig.is_some() => {
                self.flush();
                self.open = Open::Caption;
                Kind::Caption
            }
            _ if BLOCKISH.contains(&n) => {
                self.boundary();
                Kind::Block
            }
            _ => Kind::Plain,
        }
    }

    /// Code by stylesheet: a monospace `p` is a code line, a monospace `span` inline code.
    fn mono_kind(&mut self, n: &str, e: &BytesStart<'_>) -> Option<Kind> {
        let class = attr(e, "class")?;
        let mono = |c| self.mono.iter().any(|set| set.contains(c));
        if !class.split_whitespace().any(mono) {
            return None;
        }
        match n {
            "span" => Some(Kind::Code),
            "p" if self.pre.is_none()
                && self.table.is_none()
                && self.fig.is_none()
                && !self.frames.iter().any(|f| matches!(f.kind, Kind::Li)) =>
            {
                self.flush();
                self.pre = Some(String::new());
                self.pre_merge = true;
                Some(Kind::Pre)
            }
            _ => None,
        }
    }

    /// A monospace paragraph with a link or image cannot be a code line (it
    /// would be lost): the paragraph goes on as running text in code style.
    pub(super) fn demote_code_paragraph(&mut self) {
        if !std::mem::take(&mut self.pre_merge) {
            return;
        }
        let Some(text) = self.pre.take() else { return };
        if let Some(f) = self
            .frames
            .iter_mut()
            .rev()
            .find(|f| matches!(f.kind, Kind::Pre))
        {
            f.kind = Kind::CodeParagraph;
        }
        self.counts.code += 1;
        let text = text.trim_start_matches([' ', '\n']);
        if !text.is_empty() {
            self.open = Open::Para;
            // the buffered text is plain code: styles around the link are not its own
            let code_only = Counts {
                code: self.counts.code,
                ..Counts::default()
            };
            let around = std::mem::replace(&mut self.counts, code_only);
            self.push_text(text.to_owned());
            self.counts = around;
        }
    }

    pub(super) fn footnote_start(&mut self, e: &BytesStart<'_>) -> bool {
        if self.containers.len() >= MAX_CONTAINER_DEPTH {
            return false;
        }
        let Some(id) = attr(e, "id") else {
            return false;
        };
        if !(has_token(attr(e, "type"), &NOTE_TYPES) || has_token(attr(e, "role"), &NOTE_TYPES)) {
            return false;
        }
        self.flush();
        let id = format!("{}#{id}", self.chapter);
        self.containers.push(Container {
            kind: ContainerKind::Footnote(id),
            blocks: Vec::new(),
        });
        true
    }

    pub(super) fn link_start(&mut self, e: &BytesStart<'_>) -> Kind {
        let Some(kind) = attr(e, "href").and_then(|h| self.link_kind(&h)) else {
            return Kind::Plain;
        };
        self.demote_code_paragraph();
        let noteref = has_token(attr(e, "type"), &["noteref"])
            || has_token(attr(e, "role"), &["doc-noteref"]);
        self.links.push(LinkFrame {
            kind,
            noteref,
            inlines: Vec::new(),
        });
        Kind::Link(self.links.len() - 1)
    }

    pub(super) fn link_kind(&self, href: &str) -> Option<LinkKind> {
        let h = href.trim();
        if h.is_empty() {
            return None;
        }
        if let Some(scheme) = scheme_of(h) {
            let s = scheme.to_ascii_lowercase();
            return matches!(s.as_str(), "http" | "https" | "mailto")
                .then(|| LinkKind::External(h.to_owned()));
        }
        resolve(self.chapter, h).map(LinkKind::Internal)
    }

    pub(super) fn heading_start(&mut self, n: &str) -> Kind {
        if self.joined() {
            self.space();
            return Kind::Plain;
        }
        self.flush();
        let level = n
            .chars()
            .nth(1)
            .and_then(|c| c.to_digit(10))
            .unwrap_or(1)
            .min(4);
        self.open = Open::Heading(u8::try_from(level).unwrap_or(4));
        Kind::Heading
    }

    pub(super) fn list_start(&mut self, ordered: bool, e: &BytesStart<'_>) -> Kind {
        self.list_boundary();
        let next = attr(e, "start")
            .and_then(|s| s.trim().parse().ok())
            .unwrap_or(1);
        Kind::List { ordered, next }
    }

    pub(super) fn li_start(&mut self) -> Kind {
        if matches!(self.open, Open::Cell | Open::Caption) {
            self.space();
            return Kind::Plain;
        }
        self.flush();
        let depth = self
            .frames
            .iter()
            .filter(|f| matches!(f.kind, Kind::List { .. }))
            .count();
        let marker = match self
            .frames
            .iter_mut()
            .rev()
            .find_map(|f| match &mut f.kind {
                Kind::List { ordered, next } => Some((*ordered, next)),
                _ => None,
            }) {
            Some((true, next)) => {
                let m = ListMarker::Number(*next);
                *next = next.saturating_add(1);
                m
            }
            _ => ListMarker::Bullet,
        };
        let depth = u8::try_from(depth.saturating_sub(1)).unwrap_or(u8::MAX);
        self.open = Open::Item(marker, depth);
        Kind::Li
    }

    pub(super) fn table_start(&mut self) -> Kind {
        if self.table.is_some() {
            self.space();
            return Kind::NestedTable;
        }
        self.flush();
        self.table = Some(Table::default());
        Kind::Table
    }

    pub(super) fn cell_start(&mut self, n: &str) -> Kind {
        if self.table.is_none() || self.table_nest > 0 {
            self.space();
            return Kind::Plain;
        }
        self.finish_cell();
        if n == "tr" {
            self.finish_row();
        }
        if let Some(t) = self.table.as_mut() {
            t.row.get_or_insert_with(Vec::new);
        }
        if n == "tr" {
            return Kind::Tr;
        }
        self.flush();
        self.open = Open::Cell;
        Kind::Cell
    }

    pub(super) fn void(&mut self, n: &str, e: &BytesStart<'_>) {
        match n {
            "br" => {
                if let Some(p) = self.pre.as_mut() {
                    p.push('\n');
                } else if self.open != Open::None {
                    self.push_text("\n".into());
                }
            }
            "img" => self.image(attr(e, "src")),
            "hr" => {
                self.flush();
                self.push_block(DBlock::Separator);
            }
            _ => {}
        }
    }

    pub(super) fn image(&mut self, src: Option<String>) {
        let Some(id) = src.and_then(|s| self.images.load(self.chapter, &s)) else {
            return;
        };
        self.demote_code_paragraph();
        if let Some(f) = self.fig.as_mut() {
            if self.open != Open::Caption && f.image.is_none() {
                f.image = Some(id);
                return;
            }
        }
        if self.open == Open::None {
            self.open = Open::Para;
        }
        self.target().push(DInline::Image(id));
    }
}
