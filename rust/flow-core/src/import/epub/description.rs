//! Plain text from `dc:description`, which is often escaped HTML.
use super::entities;

/// Longest description kept, in `char`s; the rest is replaced by `…`.
pub(super) const MAX_DESCRIPTION_CHARS: usize = 10_000;

/// Plain-text paragraphs (joined by `"\n\n"`) of an OPF description; `None` when nothing is left.
pub(super) fn plain_description(raw: &str) -> Option<String> {
    let mut paragraphs: Vec<String> = Vec::new();
    let mut kept = 0usize; // chars in `paragraphs` plus `cur`, separators excluded
    let mut cur = String::new(); // whitespace already collapsed, may end with one space
    let mut flush = |cur: &mut String, kept: &mut usize| {
        let text = cur.trim_end();
        if text.is_empty() {
            *kept -= cur.len(); // only a pending space, `cur` never starts with one
        } else {
            *kept -= cur.len() - text.len();
            paragraphs.push(text.to_owned());
        }
        cur.clear();
    };
    let push = |cur: &mut String, kept: &mut usize, text: &str| {
        for c in text.chars() {
            if c.is_whitespace() {
                if !cur.is_empty() && !cur.ends_with(' ') {
                    cur.push(' ');
                    *kept += 1;
                }
            } else {
                cur.push(c);
                *kept += 1;
            }
        }
    };
    let mut rest = raw;
    while let Some(c) = rest.chars().next() {
        if kept > MAX_DESCRIPTION_CHARS {
            break; // the rest would be cut off anyway
        }
        match c {
            '<' if let Some(len) = tag_len(rest) => {
                if is_block_tag(rest.get(1..len).unwrap_or_default()) {
                    flush(&mut cur, &mut kept);
                }
                rest = rest.get(len..).unwrap_or_default();
            }
            '&' => {
                let (text, used) = entity(rest);
                push(&mut cur, &mut kept, &text);
                rest = rest.get(used..).unwrap_or_default();
            }
            _ => {
                push(&mut cur, &mut kept, c.encode_utf8(&mut [0; 4]));
                rest = rest.get(c.len_utf8()..).unwrap_or_default();
            }
        }
    }
    flush(&mut cur, &mut kept);
    let mut text = paragraphs.join("\n\n");
    if let Some((cut, _)) = text.char_indices().nth(MAX_DESCRIPTION_CHARS) {
        text.truncate(cut);
        text.push('…');
    }
    (!text.is_empty()).then_some(text)
}

/// Byte length of the markup at the start of `s` (`s` begins with `<`), or `None` when the `<`
/// is plain text (not followed by a letter, `/`, `!` or `?`). Unclosed markup runs to the end.
fn tag_len(s: &str) -> Option<usize> {
    let after = s.get(1..)?;
    if !after.starts_with(|c: char| c.is_ascii_alphabetic() || matches!(c, '/' | '!' | '?')) {
        return None;
    }
    if after.starts_with("!--") {
        return Some(s.find("-->").map_or(s.len(), |i| i + 3));
    }
    let mut quote = None;
    for (i, c) in s.char_indices() {
        match (quote, c) {
            (Some(q), _) if c == q => quote = None,
            (None, '"' | '\'') => quote = Some(c),
            (None, '>') => return Some(i + 1),
            _ => {}
        }
    }
    Some(s.len())
}

/// Tags that start a new paragraph; `tag` is the text between `<` and `>`.
fn is_block_tag(tag: &str) -> bool {
    let name: String = tag
        .trim_start_matches('/')
        .chars()
        .take_while(char::is_ascii_alphanumeric)
        .collect::<String>()
        .to_ascii_lowercase();
    matches!(
        name.as_str(),
        "p" | "div" | "br" | "li" | "h1" | "h2" | "h3" | "h4" | "h5" | "h6"
    )
}

/// Longest entity name looked at; anything longer is plain text.
const MAX_ENTITY_LEN: usize = 32;

/// Decodes the entity at the start of `s` (`s` begins with `&`): the text and the bytes used.
/// Unknown or malformed entities give `"&"` and one byte, so the rest stays text.
fn entity(s: &str) -> (String, usize) {
    let literal = ("&".to_owned(), 1);
    let Some(end) = s.bytes().take(MAX_ENTITY_LEN).position(|b| b == b';') else {
        return literal;
    };
    let name = &s[1..end];
    let decoded = match name.strip_prefix('#') {
        Some(num) => match num.strip_prefix(['x', 'X']) {
            Some(hex) => digits(hex, 16),
            None => digits(num, 10),
        }
        .and_then(char::from_u32)
        .filter(|c| !c.is_control() || matches!(c, '\n' | '\t')),
        None => entities::named(name),
    };
    decoded.map_or(literal, |c| (c.to_string(), end + 1))
}

/// Value of `s` written in `radix` with digits only (no sign, not empty).
fn digits(s: &str, radix: u32) -> Option<u32> {
    s.chars()
        .all(|c| c.is_digit(radix))
        .then(|| u32::from_str_radix(s, radix).ok())
        .flatten()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn strips_tags_into_paragraphs() {
        assert_eq!(
            plain_description("<p>Один</p><p>Два <b>три</b></p>").as_deref(),
            Some("Один\n\nДва три")
        );
    }

    #[test]
    fn br_and_div_split_paragraphs() {
        assert_eq!(
            plain_description("a<br/>b<div>c</div>").as_deref(),
            Some("a\n\nb\n\nc")
        );
    }

    #[test]
    fn decodes_entities() {
        assert_eq!(
            plain_description("A&amp;B&nbsp;C &#8212; &#x2014; &foo;").as_deref(),
            Some("A&B C — — &foo;")
        );
    }

    #[test]
    fn plain_text_is_kept() {
        assert_eq!(
            plain_description("  Просто   текст \n").as_deref(),
            Some("Просто текст")
        );
    }

    #[test]
    fn empty_becomes_none() {
        assert_eq!(plain_description(""), None);
        assert_eq!(plain_description("<p> </p>"), None);
    }

    #[test]
    fn unclosed_tag_is_dropped() {
        assert_eq!(plain_description("текст <b").as_deref(), Some("текст"));
    }

    #[test]
    fn long_text_is_truncated() {
        let got = plain_description(&"я".repeat(20_000)).unwrap();
        assert_eq!(got.chars().count(), MAX_DESCRIPTION_CHARS + 1);
        assert!(got.ends_with('…'));
    }

    #[test]
    fn entity_before_multibyte_text() {
        assert_eq!(
            plain_description("&amp;привет мир привет мир").as_deref(),
            Some("&привет мир привет мир")
        );
    }

    #[test]
    fn bad_numeric_entities_stay_text() {
        assert_eq!(
            plain_description("&#xD800; &#99999999; &#;").as_deref(),
            Some("&#xD800; &#99999999; &#;")
        );
    }

    #[test]
    fn lone_less_than_is_text() {
        assert_eq!(
            plain_description("a < b and c > d").as_deref(),
            Some("a < b and c > d")
        );
        assert_eq!(
            plain_description("1 < 2 tail text").as_deref(),
            Some("1 < 2 tail text")
        );
    }

    #[test]
    fn comments_and_quoted_gt_are_dropped_whole() {
        assert_eq!(plain_description("a<!-- x >y -->b").as_deref(), Some("ab"));
        assert_eq!(
            plain_description(r#"a<a title="x>y">b</a>"#).as_deref(),
            Some("ab")
        );
        assert_eq!(
            plain_description("a<!-- never closed").as_deref(),
            Some("a")
        );
    }

    #[test]
    fn odd_numeric_entities_stay_text() {
        for raw in ["&#+65;", "&#x+41;", "&#0;", "&#1;", "&#x7F;"] {
            assert_eq!(plain_description(raw).as_deref(), Some(raw), "{raw}");
        }
        assert_eq!(plain_description("&#65;&#x42;").as_deref(), Some("AB"));
    }

    #[test]
    fn parsing_stops_after_the_limit() {
        // A huge tail must not change the result of the kept prefix.
        let raw = format!(
            "{}{}",
            "я".repeat(MAX_DESCRIPTION_CHARS + 5),
            "<b>".repeat(100_000)
        );
        let got = plain_description(&raw).unwrap();
        assert_eq!(got.chars().count(), MAX_DESCRIPTION_CHARS + 1);
        let spaced = format!("{}{}", "я ".repeat(MAX_DESCRIPTION_CHARS), "z");
        let got = plain_description(&spaced).unwrap();
        assert_eq!(got.chars().count(), MAX_DESCRIPTION_CHARS + 1);
        assert!(got.ends_with("я …") || got.ends_with('…'));
    }
}
