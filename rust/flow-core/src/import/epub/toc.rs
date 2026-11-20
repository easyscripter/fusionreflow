//! Table-of-contents documents: EPUB 3 `nav` and EPUB 2 NCX, as drafts
//! whose targets are resolved to blocks later.
use super::path::{resolve, Target};
use super::xml::{attr, collapse, end_name, event_text, name, reader};
use quick_xml::events::Event;

/// One contents entry before its target is mapped to a block.
#[derive(Debug)]
pub(super) struct Draft {
    pub level: usize,
    pub title: String,
    pub target: Option<Target>,
}

fn finish(mut v: Vec<Draft>) -> Vec<Draft> {
    for d in &mut v {
        d.title = collapse(&d.title);
    }
    v
}

/// Entries of the first `<nav epub:type="toc">`; malformed input keeps what was read.
pub(super) fn parse_nav(xml: &str, nav_path: &str) -> Vec<Draft> {
    let mut r = reader(xml, false);
    let mut out = Vec::new();
    let (mut in_nav, mut done, mut depth) = (false, false, 0usize);
    let mut cur: Option<Draft> = None;
    while let Ok(ev) = r.read_event() {
        if let (Some(d), Some(t)) = (cur.as_mut(), event_text(&ev)) {
            d.title.push_str(&t);
            continue;
        }
        match ev {
            Event::Start(e) => match name(&e).as_str() {
                "nav"
                    if !done
                        && attr(&e, "type")
                            .is_some_and(|t| t.split_whitespace().any(|x| x == "toc")) =>
                {
                    in_nav = true;
                }
                "ol" if in_nav => depth += 1,
                "a" if in_nav => {
                    cur = Some(Draft {
                        level: depth.max(1),
                        title: String::new(),
                        target: attr(&e, "href").and_then(|h| resolve(nav_path, &h)),
                    });
                }
                _ => {}
            },
            Event::End(e) => match end_name(&e).as_str() {
                "nav" if in_nav => {
                    in_nav = false;
                    done = true;
                }
                "ol" if in_nav => depth = depth.saturating_sub(1),
                "a" => out.extend(cur.take()),
                _ => {}
            },
            Event::Eof => break,
            _ => {}
        }
    }
    finish(out)
}

/// Entries of an NCX `navMap`, nested `navPoint`s become deeper levels.
pub(super) fn parse_ncx(xml: &str, ncx_path: &str) -> Vec<Draft> {
    let mut r = reader(xml, false);
    let mut out: Vec<Draft> = Vec::new();
    let mut stack: Vec<usize> = Vec::new();
    let mut in_label = false;
    while let Ok(ev) = r.read_event() {
        if in_label {
            if let (Some(&i), Some(t)) = (stack.last(), event_text(&ev)) {
                if let Some(d) = out.get_mut(i) {
                    d.title.push_str(&t);
                }
                continue;
            }
        }
        match ev {
            Event::Start(e) | Event::Empty(e) => match name(&e).as_str() {
                "navpoint" => {
                    stack.push(out.len());
                    out.push(Draft {
                        level: stack.len(),
                        title: String::new(),
                        target: None,
                    });
                }
                "navlabel" => in_label = true,
                "content" => {
                    if let Some(d) = stack.last().and_then(|&i| out.get_mut(i)) {
                        d.target = attr(&e, "src").and_then(|s| resolve(ncx_path, &s));
                    }
                }
                _ => {}
            },
            Event::End(e) => match end_name(&e).as_str() {
                "navpoint" => {
                    stack.pop();
                }
                "navlabel" => in_label = false,
                _ => {}
            },
            Event::Eof => break,
            _ => {}
        }
    }
    finish(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn nav_levels_and_titles() {
        let x = r#"<html xmlns:epub="e"><body><nav epub:type="toc"><ol><li><a href="a.xhtml"> A  <b>x</b></a><ol><li><a href="b.xhtml#i">B</a></li></ol></li></ol></nav></body></html>"#;
        let d = parse_nav(x, "o/nav.xhtml");
        assert_eq!(d.len(), 2);
        assert_eq!((d[0].level, d[0].title.as_str()), (1, "A x"));
        assert_eq!(d[1].level, 2);
        assert_eq!(
            d[1].target.as_ref().map(|t| t.path.as_str()),
            Some("o/b.xhtml")
        );
    }

    #[test]
    fn ncx_nesting_even_when_content_precedes_label() {
        let x = r#"<ncx><navMap><navPoint><content src="a.x"/><navLabel><text>A</text></navLabel><navPoint><navLabel><text>B</text></navLabel><content src="b.x"/></navPoint></navPoint></navMap></ncx>"#;
        let d = parse_ncx(x, "toc.ncx");
        assert_eq!(
            d.iter()
                .map(|d| (d.level, d.title.as_str()))
                .collect::<Vec<_>>(),
            [(1, "A"), (2, "B")]
        );
    }

    #[test]
    fn broken_input_yields_prefix() {
        assert!(parse_nav("<nav", "n").is_empty());
    }
}
