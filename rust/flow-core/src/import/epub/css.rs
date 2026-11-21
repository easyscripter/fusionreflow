//! Minimal stylesheet reading: which classes the book sets in a monospace font.
//! Many books mark code only this way (`p.listing { font-family: monospace }`).
use super::xml::{attr, end_name, name, reader};
use quick_xml::events::Event;
use std::collections::HashSet;

/// Font family names that make a class "code" (lowercase substrings).
const MONO_FONTS: [&str; 3] = ["mono", "consol", "courier"];

/// `href`s of the `<link rel="stylesheet">` elements in the document head.
pub(super) fn stylesheet_hrefs(xml: &str) -> Vec<String> {
    let mut r = reader(xml, false);
    let mut out = Vec::new();
    loop {
        match r.read_event() {
            Ok(Event::Start(e) | Event::Empty(e)) => match name(&e).as_str() {
                "link"
                    if attr(&e, "rel").is_some_and(|v| v.to_lowercase().contains("stylesheet")) =>
                {
                    out.extend(attr(&e, "href"));
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

fn strip_comments(css: &str) -> String {
    let mut out = String::with_capacity(css.len());
    let mut rest = css;
    while let Some(i) = rest.find("/*") {
        out.push_str(&rest[..i]);
        rest = rest[i..].split_once("*/").map_or("", |(_, tail)| tail);
    }
    out.push_str(rest);
    out
}

fn is_mono(decls: &str) -> bool {
    decls.split(';').any(|d| {
        d.split_once(':').is_some_and(|(k, v)| {
            let v = v.to_lowercase();
            k.trim().eq_ignore_ascii_case("font-family") && MONO_FONTS.iter().any(|f| v.contains(f))
        })
    })
}

/// Class names of rules whose `font-family` is monospace. Only the last
/// compound selector counts and the tag is ignored (`p.a` and `span.a` both give `a`).
// shortcut: no cascade, specificity or descendant selectors; revisit if a book needs them.
pub(super) fn mono_classes(css: &str) -> HashSet<String> {
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
        for sel in selectors.split(',') {
            let Some(last) = sel.split_whitespace().next_back() else {
                continue;
            };
            if last.contains([':', '[', '>', '+', '~']) {
                continue;
            }
            for part in last.split('.').skip(1) {
                let class = part.split('#').next().unwrap_or_default();
                if !class.is_empty() {
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

    #[test]
    fn finds_classes_with_comments_and_groups() {
        let css = "/* a { font-family: monospace } */ p.a, span.b {font-family: 'Courier New'} .c{font-family: serif} @media print { .d { font-family: monospace } } p.e:hover{font-family:monospace}";
        let m = mono_classes(css);
        let mut v: Vec<_> = m.iter().map(String::as_str).collect();
        v.sort_unstable();
        assert_eq!(v, ["a", "b", "d"]);
    }

    #[test]
    fn finds_stylesheet_links_only_in_head() {
        let x = r#"<html><head><link rel="stylesheet" href="a.css"/><link rel="icon" href="i"/></head><body><link rel="stylesheet" href="b.css"/></body></html>"#;
        assert_eq!(stylesheet_hrefs(x), ["a.css"]);
    }

    #[test]
    fn unterminated_comment_and_junk_do_not_panic() {
        assert!(mono_classes("/* x { .a {font-family: mono}").is_empty());
        assert!(mono_classes("}}{{ ;; font-family").is_empty());
    }
}
