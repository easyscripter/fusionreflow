//! Small helpers over `quick-xml` shared by every EPUB part.
use super::entities;
use quick_xml::events::{BytesEnd, BytesRef, BytesStart, Event};
use quick_xml::Reader;
use quick_xml::XmlVersion;

/// A reader over `text`. `strict` demands matching end tags (package files);
/// lenient mode tolerates sloppy chapters.
pub(super) fn reader(text: &str, strict: bool) -> Reader<&[u8]> {
    let mut r = Reader::from_str(text);
    let c = r.config_mut();
    c.check_end_names = strict;
    c.allow_unmatched_ends = !strict;
    r
}

/// Decodes document bytes: UTF-8 (BOM dropped, bad bytes → U+FFFD) or UTF-16 by BOM.
pub(super) fn decode_bytes(bytes: &[u8]) -> String {
    let utf16 = |rest: &[u8], le: bool| {
        let units: Vec<u16> = rest
            .as_chunks::<2>()
            .0
            .iter()
            .map(|&pair| {
                if le {
                    u16::from_le_bytes(pair)
                } else {
                    u16::from_be_bytes(pair)
                }
            })
            .collect();
        String::from_utf16_lossy(&units)
    };
    match bytes {
        [0xFF, 0xFE, rest @ ..] => utf16(rest, true),
        [0xFE, 0xFF, rest @ ..] => utf16(rest, false),
        [0xEF, 0xBB, 0xBF, rest @ ..] => String::from_utf8_lossy(rest).into_owned(),
        _ => String::from_utf8_lossy(bytes).into_owned(),
    }
}

/// Local (prefix-less) element name, lowercased.
pub(super) fn name(e: &BytesStart<'_>) -> String {
    e.local_name().as_ref().to_lowercase()
}

/// Local end-tag name, lowercased.
pub(super) fn end_name(e: &BytesEnd<'_>) -> String {
    e.local_name().as_ref().to_lowercase()
}

/// Value of the attribute whose local name is `local` (`epub:type` → `type`).
pub(super) fn attr(e: &BytesStart<'_>, local: &str) -> Option<String> {
    e.attributes().with_checks(false).flatten().find_map(|a| {
        (a.key.local_name().as_ref() == local).then(|| {
            a.normalized_value(XmlVersion::Implicit1_0)
                .map_or_else(|_| a.value.to_string(), |v| v.into_owned())
        })
    })
}

/// Whether the space-separated attribute `value` holds one of `tokens`.
pub(super) fn has_token(value: Option<String>, tokens: &[&str]) -> bool {
    value.is_some_and(|v| v.split_whitespace().any(|t| tokens.contains(&t)))
}

/// Text of a character or entity reference; unknown names stay as `&name;`.
pub(super) fn ref_text(r: &BytesRef<'_>) -> String {
    match r.resolve_char_ref() {
        Ok(Some(c)) => c.to_string(),
        Err(_) => '\u{FFFD}'.to_string(),
        Ok(None) => {
            let n = r.html_content();
            entities::named(&n).map_or_else(|| format!("&{n};"), |c| c.to_string())
        }
    }
}

/// Text carried by a text-like event, if any.
pub(super) fn event_text(ev: &Event<'_>) -> Option<String> {
    match ev {
        Event::Text(t) => Some(t.html_content().into_owned()),
        Event::CData(c) => Some(c.html_content().into_owned()),
        Event::GeneralRef(r) => Some(ref_text(r)),
        _ => None,
    }
}

/// Collapses whitespace runs to single spaces and trims.
pub(super) fn collapse(s: &str) -> String {
    s.split_whitespace().collect::<Vec<_>>().join(" ")
}
