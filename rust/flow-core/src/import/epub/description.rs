//! Plain text from `dc:description`, which is often escaped HTML.
use super::entities;

/// Longest description kept, in `char`s; the rest is replaced by `…`.
pub(super) const MAX_DESCRIPTION_CHARS: usize = 10_000;

/// Plain-text paragraphs (joined by `"\n\n"`) of an OPF description; `None` when nothing is left.
pub(super) fn plain_description(raw: &str) -> Option<String> {
    let mut paragraphs: Vec<String> = Vec::new();
    let mut cur = String::new();
    let mut flush = |cur: &mut String| {
        let text = cur.split_whitespace().collect::<Vec<_>>().join(" ");
        cur.clear();
        if !text.is_empty() {
            paragraphs.push(text);
        }
    };
    let mut rest = raw;
    while let Some(c) = rest.chars().next() {
        match c {
            '<' => {
                let Some(end) = rest.find('>') else { break };
                if is_block_tag(&rest[1..end]) {
                    flush(&mut cur);
                }
                rest = &rest[end + 1..];
            }
            '&' => {
                let (text, used) = entity(rest);
                cur.push_str(&text);
                rest = &rest[used..];
            }
            _ => {
                cur.push(c);
                rest = &rest[c.len_utf8()..];
            }
        }
    }
    flush(&mut cur);
    let mut text = paragraphs.join("\n\n");
    if let Some((cut, _)) = text.char_indices().nth(MAX_DESCRIPTION_CHARS) {
        text.truncate(cut);
        text.push('…');
    }
    (!text.is_empty()).then_some(text)
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
            Some(hex) => u32::from_str_radix(hex, 16).ok(),
            None => num.parse().ok(),
        }
        .and_then(char::from_u32),
        None => entities::named(name),
    };
    decoded.map_or(literal, |c| (c.to_string(), end + 1))
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
}
