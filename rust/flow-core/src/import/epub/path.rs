//! Resolving `href`s inside an archive: relative paths, `%`-decoding, fragments.

/// A resolved reference: archive path (no leading slash) and optional fragment.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(super) struct Target {
    pub path: String,
    pub fragment: Option<String>,
}

fn percent_decode(s: &str) -> String {
    let b = s.as_bytes();
    let mut out = Vec::with_capacity(b.len());
    let mut i = 0;
    while let Some(&c) = b.get(i) {
        let hex = |k: usize| b.get(k).and_then(|d| char::from(*d).to_digit(16));
        match (c, hex(i + 1), hex(i + 2)) {
            (b'%', Some(h), Some(l)) => {
                out.push(u8::try_from(h * 16 + l).unwrap_or(b'?'));
                i += 3;
            }
            _ => {
                out.push(c);
                i += 1;
            }
        }
    }
    String::from_utf8_lossy(&out).into_owned()
}

/// Resolves `href` against the archive path `base` (the file that contains it).
/// `None` when the path escapes the archive root.
pub(super) fn resolve(base: &str, href: &str) -> Option<Target> {
    let (path_part, fragment) = match href.split_once('#') {
        Some((p, f)) => (p, Some(percent_decode(f))),
        None => (href, None),
    };
    let path_part = path_part.split('?').next().unwrap_or_default();
    let decoded = percent_decode(path_part).replace('\\', "/");
    let mut parts: Vec<&str> = Vec::new();
    let joined;
    let full = if decoded.is_empty() {
        base
    } else if decoded.starts_with('/') {
        decoded.as_str()
    } else {
        let dir = base.rsplit_once('/').map_or("", |(d, _)| d);
        joined = format!("{dir}/{decoded}");
        joined.as_str()
    };
    for seg in full.split('/') {
        match seg {
            "" | "." => {}
            ".." => {
                parts.pop()?;
            }
            s => parts.push(s),
        }
    }
    Some(Target {
        path: parts.join("/"),
        fragment,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn r(base: &str, href: &str) -> Option<(String, Option<String>)> {
        resolve(base, href).map(|t| (t.path, t.fragment))
    }

    #[test]
    fn relative_and_dotdot() {
        assert_eq!(r("a/b.xhtml", "../c.xhtml"), Some(("c.xhtml".into(), None)));
        assert_eq!(
            r("a/b.xhtml", "./x/y.png"),
            Some(("a/x/y.png".into(), None))
        );
    }

    #[test]
    fn escape_is_none() {
        assert_eq!(r("a.xhtml", "../x"), None);
        assert_eq!(r("a/b.xhtml", "../../x"), None);
    }

    #[test]
    fn percent_fragment_query_backslash_absolute() {
        assert_eq!(
            r("a/b.xhtml", "my%20ch.xhtml#id%31"),
            Some(("a/my ch.xhtml".into(), Some("id1".into())))
        );
        assert_eq!(
            r("a/b.xhtml", "#frag"),
            Some(("a/b.xhtml".into(), Some("frag".into())))
        );
        assert_eq!(
            r("a/b.xhtml", "c.xhtml?x=1"),
            Some(("a/c.xhtml".into(), None))
        );
        assert_eq!(
            r("a/b.xhtml", "d\\e.xhtml"),
            Some(("a/d/e.xhtml".into(), None))
        );
        assert_eq!(
            r("a/b.xhtml", "/OEBPS/x.png"),
            Some(("OEBPS/x.png".into(), None))
        );
        assert_eq!(r("a/b.xhtml", "%zz"), Some(("a/%zz".into(), None)));
    }
}
