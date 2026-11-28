//! Minimal stylesheet reading: which classes the book sets in a monospace font.
//! Many books mark code only this way (`p.listing { font-family: monospace }`).
//! A broken or oversized stylesheet is skipped, never fatal.
use super::archive::{Archive, ArchiveError};
use super::xml::{attr, decode_bytes, end_name, has_token, name, reader};
use quick_xml::events::Event;
use std::collections::{HashMap, HashSet};

/// A larger stylesheet is ignored.
const MAX_CSS_BYTES: usize = 1 << 20;
/// Distinct stylesheets looked at per chapter.
const MAX_SHEETS_PER_CHAPTER: usize = 16;
/// Distinct stylesheets read per book.
const MAX_SHEETS_PER_BOOK: usize = 64;
/// Monospace classes kept per stylesheet.
const MAX_CLASSES: usize = 1024;

/// `href`s of the `<link rel="stylesheet">` elements in the document head.
fn stylesheet_hrefs(xml: &str) -> Vec<String> {
    let mut r = reader(xml, false);
    let mut out = Vec::new();
    loop {
        match r.read_event() {
            Ok(Event::Start(e) | Event::Empty(e)) => match name(&e).as_str() {
                "link" => {
                    let rel = attr(&e, "rel").map(|v| v.to_lowercase());
                    if has_token(rel, &["stylesheet"]) {
                        out.extend(attr(&e, "href"));
                    }
                }
                "body" => break,
                _ => {}
            },
            Ok(Event::End(e)) if end_name(&e) == "head" => break,
            Ok(Event::Eof) | Err(_) => break,
            _ => {}
        }
    }
    out
}

/// Monospace classes per stylesheet entry, each read once per book.
#[derive(Default)]
pub(super) struct Stylesheets(HashMap<String, HashSet<String>>);

impl Stylesheets {
    /// Class sets of the stylesheets a chapter links. The only error is the
    /// archive-wide size limit.
    pub fn for_chapter(
        &mut self,
        a: &mut Archive<'_>,
        chapter: &str,
        xml: &str,
    ) -> Result<Vec<&HashSet<String>>, ArchiveError> {
        let mut seen = HashSet::new();
        let mut paths = Vec::new();
        for href in stylesheet_hrefs(xml) {
            if paths.len() >= MAX_SHEETS_PER_CHAPTER {
                break;
            }
            if !seen.insert(href.clone()) {
                continue;
            }
            let Some(path) = a.locate(chapter, &href) else {
                continue;
            };
            if paths.contains(&path) {
                continue;
            }
            if !self.0.contains_key(&path) {
                if self.0.len() >= MAX_SHEETS_PER_BOOK {
                    continue;
                }
                let classes = match a.read(&path) {
                    Ok(b) if b.len() <= MAX_CSS_BYTES => mono_classes(&decode_bytes(&b)),
                    Err(ArchiveError::TotalTooLarge) => return Err(ArchiveError::TotalTooLarge),
                    _ => HashSet::new(),
                };
                self.0.insert(path.clone(), classes);
            }
            paths.push(path);
        }
        Ok(paths.iter().filter_map(|p| self.0.get(p)).collect())
    }
}

fn strip_comments(css: &str) -> String {
    let mut out = String::with_capacity(css.len());
    let mut rest = css;
    while let Some((before, after)) = rest.split_once("/*") {
        out.push_str(before);
        rest = after.split_once("*/").map_or("", |(_, tail)| tail);
    }
    out.push_str(rest);
    out
}

/// A monospace family name: `monospace`, or a word like `Mono`, `UbuntuMono`,
/// `Consolas`, `Courier` (but not `Monotype` or `Monomakh`).
fn is_mono_name(family: &str) -> bool {
    family.split([' ', '-', '_']).any(|w| {
        w == "monospace"
            || w.ends_with("mono")
            || matches!(w, "consol" | "consola" | "consolas")
            || w.starts_with("courier")
    })
}

/// Only the first family of the list counts, plus the generic `monospace`.
fn is_mono(decls: &str) -> bool {
    decls.split(';').any(|d| {
        let Some((key, value)) = d.split_once(':') else {
            return false;
        };
        if !key.trim().eq_ignore_ascii_case("font-family") {
            return false;
        }
        let value = value.to_lowercase();
        let value = value.split('!').next().unwrap_or_default();
        let mut families = value
            .split(',')
            .map(|f| f.trim_matches(|c: char| c.is_whitespace() || c == '"' || c == '\''));
        families.next().is_some_and(is_mono_name) || families.any(|f| f == "monospace")
    })
}

/// Class names of `.a` / `tag.a` rules whose `font-family` is monospace; the tag
/// is ignored. Descendant, compound (`.a.b`) and pseudo selectors are skipped:
/// taking one of their classes alone would turn body text into code.
// shortcut: no cascade, specificity or `font:` shorthand; revisit if a book needs them.
fn mono_classes(css: &str) -> HashSet<String> {
    let css = strip_comments(css);
    let mut out = HashSet::new();
    for rule in css.split('}') {
        let Some((head, decls)) = rule.rsplit_once('{') else {
            continue;
        };
        if !is_mono(decls) {
            continue;
        }
        let selectors = head.rsplit(['{', ';']).next().unwrap_or_default();
        for sel in selectors.split(',').map(str::trim) {
            if sel.contains(|c: char| c.is_whitespace() || ":[>+~#".contains(c)) {
                continue;
            }
            let mut parts = sel.split('.').skip(1);
            if let (Some(class), None) = (parts.next(), parts.next()) {
                if !class.is_empty() && out.len() < MAX_CLASSES {
                    out.insert(class.to_owned());
                }
            }
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sorted(css: &str) -> Vec<String> {
        let mut v: Vec<_> = mono_classes(css).into_iter().collect();
        v.sort_unstable();
        v
    }

    #[test]
    fn finds_simple_selectors_with_comments_groups_and_media() {
        let css = "/* a { font-family: monospace } */ p.a, span.b {font-family: 'Courier New'} .c{font-family: serif} @media print { .d { font-family: monospace } } p.e:hover{font-family:monospace}";
        assert_eq!(sorted(css), ["a", "b", "d"]);
    }

    #[test]
    fn class_count_is_capped() {
        let css: String = (0..MAX_CLASSES + 10)
            .map(|i| format!(".c{i},"))
            .collect::<String>()
            + ".z{font-family:monospace}";
        assert_eq!(mono_classes(&css).len(), MAX_CLASSES);
    }

    #[test]
    fn finds_stylesheet_links_only_in_head() {
        let x = r#"<html><head><link rel="alternate Stylesheet" href="a.css"/><link rel="nostylesheet" href="i"/></head><body><link rel="stylesheet" href="b.css"/></body></html>"#;
        assert_eq!(stylesheet_hrefs(x), ["a.css"]);
    }

    #[test]
    fn unterminated_comment_and_junk_do_not_panic() {
        assert!(mono_classes("/* x { .a {font-family: mono}").is_empty());
        assert!(mono_classes("}}{{ ;; font-family").is_empty());
    }

    use super::super::archive::Limits;
    use std::io::{Cursor, Write};

    const MONO_RULE: &[u8] = b".a{font-family:monospace}";

    /// A zip of `count` monospace stylesheets named `0.css`, `1.css`, …
    fn sheets_zip(count: usize) -> Cursor<Vec<u8>> {
        let mut z = zip::ZipWriter::new(Cursor::new(Vec::new()));
        for i in 0..count {
            z.start_file(format!("{i}.css"), zip::write::SimpleFileOptions::default())
                .expect("start");
            z.write_all(MONO_RULE).expect("write");
        }
        Cursor::new(z.finish().expect("finish").into_inner())
    }

    fn link(href: &str) -> String {
        format!(r#"<link rel="stylesheet" href="{href}"/>"#)
    }

    #[test]
    fn repeated_links_give_one_set_and_sheets_are_capped() {
        let mut src = sheets_zip(MAX_SHEETS_PER_CHAPTER + 4);
        let mut a = Archive::open(&mut src, Limits::DEFAULT).expect("zip");
        let mut sheets = Stylesheets::default();

        let same = link("0.css").repeat(100) + &link("./0.css");
        let got = sheets.for_chapter(&mut a, "c.xhtml", &same);
        assert_eq!(got.expect("sheets").len(), 1);

        let many: String = (0..MAX_SHEETS_PER_CHAPTER + 4)
            .map(|i| link(&format!("{i}.css")))
            .collect();
        let got = sheets.for_chapter(&mut a, "c.xhtml", &many);
        assert_eq!(got.expect("sheets").len(), MAX_SHEETS_PER_CHAPTER);
    }

    #[test]
    fn sheets_per_book_are_capped() {
        let mut src = sheets_zip(MAX_SHEETS_PER_BOOK + 1);
        let mut a = Archive::open(&mut src, Limits::DEFAULT).expect("zip");
        let mut sheets = Stylesheets::default();
        let mut found = |i: usize| {
            let xml = link(&format!("{i}.css"));
            let got = sheets.for_chapter(&mut a, "c.xhtml", &xml);
            got.expect("sheets").len()
        };
        assert!((0..MAX_SHEETS_PER_BOOK).all(|i| found(i) == 1));
        assert_eq!(found(MAX_SHEETS_PER_BOOK), 0);
        assert_eq!(found(0), 1, "an already read sheet still counts");
    }

    #[test]
    fn archive_size_limit_stays_fatal() {
        let mut src = sheets_zip(1);
        let limits = Limits {
            total: MONO_RULE.len() as u64 - 1,
            ..Limits::DEFAULT
        };
        let mut a = Archive::open(&mut src, limits).expect("zip");
        let got = Stylesheets::default()
            .for_chapter(&mut a, "c.xhtml", &link("0.css"))
            .map(|s| s.len());
        assert_eq!(got, Err(ArchiveError::TotalTooLarge));
    }
}
