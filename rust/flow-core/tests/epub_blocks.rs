//! EPUB import: XHTML to blocks, links, footnotes, hyphenation.
#![allow(
    clippy::expect_used,
    clippy::unwrap_used,
    clippy::panic,
    clippy::unreachable,
    clippy::indexing_slicing
)]
mod common;

use common::epub::*;
use flow_core::model::{Block, Inline, LinkTarget, ListMarker, ResourceId, Script, Style};

#[test]
fn headings_levels_clamped() {
    let b = one("<h1>a</h1><h4>b</h4><h5>c</h5><h6>d</h6>");
    let levels: Vec<u8> = b
        .blocks
        .iter()
        .map(|n| match n.block {
            Block::Heading { level, .. } => level,
            _ => 0,
        })
        .collect();
    assert_eq!(levels, [1, 4, 4, 4]);
}

#[test]
fn inline_styles_nested_and_merged() {
    let b = one("<p><b>a<i>b</i></b>c<b>d</b><b>e</b></p>");
    let bold = Style {
        bold: true,
        ..Style::default()
    };
    let both = Style {
        bold: true,
        italic: true,
        ..Style::default()
    };
    let t = |s: &str, st: &Style| Inline::Text {
        text: s.into(),
        style: st.clone(),
    };
    match &b.blocks[0].block {
        Block::Paragraph { inlines } => assert_eq!(
            inlines,
            &[
                t("a", &bold),
                t("b", &both),
                t("c", &Style::default()),
                t("de", &bold)
            ]
        ),
        other => panic!("{other:?}"),
    }
}

#[test]
fn sup_sub_and_code_styles() {
    let b = one("<p>x<sup>2</sup>y<sub>i</sub><code>c</code></p>");
    match &b.blocks[0].block {
        Block::Paragraph { inlines } => {
            let scripts: Vec<_> = inlines
                .iter()
                .map(|i| match i {
                    Inline::Text { style, .. } => (style.script, style.code),
                    _ => unreachable!(),
                })
                .collect();
            assert_eq!(
                scripts,
                [
                    (Script::Normal, false),
                    (Script::Sup, false),
                    (Script::Normal, false),
                    (Script::Sub, false),
                    (Script::Normal, true)
                ]
            );
        }
        other => panic!("{other:?}"),
    }
}

#[test]
fn br_becomes_newline() {
    let b = one("<p>a<br/>b</p>");
    assert_eq!(b.blocks.len(), 1);
    assert_eq!(text_of(&b.blocks[0].block), "a\nb");
}

#[test]
fn whitespace_collapsed_nbsp_kept() {
    let b = one("<p>  a \n b  </p><p>x&nbsp;y</p>");
    assert_eq!(paras(&b), ["a b", "x\u{a0}y"]);
}

#[test]
fn html_entities_resolved() {
    let b = one("<p>&mdash;&laquo;&#8470;&#x41;&unknownent;</p>");
    assert_eq!(paras(&b), ["—«№A&unknownent;"]);
}

#[test]
fn lists_nested_with_start() {
    let b = content();
    let items: Vec<_> = b
        .blocks
        .iter()
        .filter_map(|n| match &n.block {
            Block::ListItem {
                marker,
                depth,
                inlines,
            } => Some((*marker, *depth, plain(inlines))),
            _ => None,
        })
        .collect();
    assert_eq!(
        items,
        [
            (ListMarker::Bullet, 0, "один".to_string()),
            (ListMarker::Bullet, 1, "вложенный".to_string()),
            (ListMarker::Bullet, 0, "два".to_string()),
            (ListMarker::Number(3), 0, "три".to_string()),
            (ListMarker::Number(4), 0, "четыре".to_string()),
        ]
    );
}

#[test]
fn blockquote_becomes_quote() {
    let b = content();
    match find(&b, |bl| matches!(bl, Block::Quote { .. })).1 {
        Block::Quote { blocks } => {
            assert_eq!(blocks.len(), 1);
            assert_eq!(text_of(&blocks[0].block), "Цитата");
        }
        _ => unreachable!(),
    }
}

#[test]
fn pre_becomes_code_lines() {
    let b = content();
    match find(&b, |bl| matches!(bl, Block::Code { .. })).1 {
        Block::Code { lines } => assert_eq!(lines, &["  отступ", "вторая"]),
        _ => unreachable!(),
    }
}

#[test]
fn hr_and_table() {
    let b = content();
    find(&b, |bl| matches!(bl, Block::Separator));
    match find(&b, |bl| matches!(bl, Block::Table(_))).1 {
        Block::Table(t) => {
            let cells: Vec<Vec<String>> = t
                .rows
                .iter()
                .map(|r| r.iter().map(|c| plain(c)).collect())
                .collect();
            assert_eq!(cells, [["a", "b"], ["c", "d"]]);
        }
        _ => unreachable!(),
    }
}

#[test]
fn script_and_style_skipped() {
    let b = content();
    let all = format!("{:?}", b.blocks);
    assert!(!all.contains("script-text"));
    assert!(!all.contains("color:red"));
}

#[test]
fn figure_with_caption() {
    let b = content();
    match find(&b, |bl| matches!(bl, Block::Figure { .. })).1 {
        Block::Figure { image, caption } => {
            assert_eq!(*image, ResourceId(0));
            assert_eq!(plain(caption), "Подпись");
        }
        _ => unreachable!(),
    }
}

#[test]
fn inline_image_in_text() {
    let b = content();
    let (_, inl) = para_with(&b, "с картинкой");
    assert!(inl.iter().any(
        |i| matches!(i, Inline::Image { res: ResourceId(0), height_em } if (*height_em - 1.0).abs() < f32::EPSILON)
    ));
}

#[test]
fn same_image_one_resource() {
    let b = content();
    assert_eq!(b.resources.len(), 1);
    assert_eq!(b.resources[0].id, ResourceId(0));
}

#[test]
fn svg_image_becomes_figure() {
    let b = convert(pack("epub3-images")).expect("convert");
    let figures = b
        .blocks
        .iter()
        .filter(|n| matches!(n.block, Block::Figure { .. }))
        .count();
    // two <p><img/></p> and one svg image
    assert_eq!(figures, 3);
}

#[test]
fn missing_or_non_image_resource_dropped() {
    let b = convert(pack("epub3-images")).expect("convert");
    // cover + pic only; fake.png (text/plain) and gone.png are dropped
    assert_eq!(b.resources.len(), 2);
    let (_, inl) = para_with(&b, "Missing");
    assert!(!inl.iter().any(|i| matches!(i, Inline::Image { .. })));
    assert_eq!(plain(inl), "Missing: . Fake: .");
}

#[test]
fn external_link() {
    let b = content();
    let (_, inl) = para_with(&b, "внешняя");
    assert!(inl.iter().any(|i| matches!(i,
        Inline::Link { target: LinkTarget::External(u), .. } if u == "https://example.org")));
}

#[test]
fn internal_link_to_anchor_in_other_chapter() {
    let b = content();
    let (target, _) = para_with(&b, "Начало");
    let (_, inl) = para_with(&b, "внутренняя");
    assert!(inl.iter().any(
        |i| matches!(i, Inline::Link { target: LinkTarget::Internal(t), .. } if *t == target)
    ));
}

#[test]
fn broken_link_unwrapped() {
    let b = content();
    let (_, inl) = para_with(&b, "битая");
    assert!(!inl.iter().any(|i| matches!(i,
        Inline::Link { inlines, .. } if plain(inlines) == "битая")));
    assert!(plain(inl).contains("битая"));
}

#[test]
fn javascript_link_unwrapped() {
    let b = content();
    let (_, inl) = para_with(&b, "js");
    assert!(!inl.iter().any(|i| matches!(i,
        Inline::Link { inlines, .. } if plain(inlines) == "js")));
    assert!(plain(inl).contains("js"));
}

#[test]
fn noteref_and_footnote() {
    let b = content();
    let (_, inl) = para_with(&b, "Сноска");
    let id = inl
        .iter()
        .find_map(|i| match i {
            Inline::NoteRef { id, label } => {
                assert_eq!(label, "1");
                Some(id.clone())
            }
            _ => None,
        })
        .expect("noteref");
    assert_eq!(id, "OEBPS/ch1.xhtml#n1");
    match find(&b, |bl| matches!(bl, Block::Footnote { .. })).1 {
        Block::Footnote { id: fid, blocks } => {
            assert_eq!(fid, &id);
            assert_eq!(text_of(&blocks[0].block), "Текст сноски");
        }
        _ => unreachable!(),
    }
}

#[test]
fn noteref_without_footnote_is_link() {
    let b = content();
    let (_, inl) = para_with(&b, "не-сноска");
    let (plain_idx, _) = para_with(&b, "Простой абзац");
    assert!(inl.iter().any(|i| matches!(i,
        Inline::Link { target: LinkTarget::Internal(t), .. } if *t == plain_idx)));
}

#[test]
fn text_inside_content_fixture_is_normalized() {
    let b = content();
    let (_, inl) = para_with(&b, "x\u{a0}y");
    assert_eq!(plain(inl), "x\u{a0}y —«z");
    assert_eq!(
        norm(&plain(para_with(&b, "Обычный").1)),
        "Обычный жирный и курсив и код x2 yi\nвторая строка"
    );
}

#[test]
fn hyphenation_applied_ru() {
    let w = "информационный";
    let b = convert(epub_with(
        "ru",
        &[&format!("<p>{w}</p><pre>{w}</pre><p><code>{w}</code></p>")],
        &[],
    ))
    .expect("convert");
    assert!(format!("{:?}", b.blocks[0].block).contains("\\u{ad}"));
    match &b.blocks[1].block {
        Block::Code { lines } => assert!(!lines[0].contains("\\u{ad}")),
        o => panic!("{o:?}"),
    }
    assert!(!format!("{:?}", b.blocks[2].block).contains("\\u{ad}"));
}

#[test]
fn hyphenation_skipped_for_other_language() {
    let b = convert(epub_with("de", &["<p>информационный</p>"], &[])).expect("convert");
    assert!(!format!("{:?}", b.blocks).contains("\\u{ad}"));
}

#[test]
fn deep_blockquotes_roundtrip_through_codec() {
    let body = format!(
        "{}<p>deep</p>{}",
        "<blockquote>".repeat(100),
        "</blockquote>".repeat(100)
    );
    let b = one(&body);
    assert!(format!("{:?}", b.blocks).contains("deep"));
    roundtrips(&b);
}

#[test]
fn deep_footnotes_roundtrip_through_codec() {
    let open: String = (0..100)
        .map(|i| format!(r#"<aside epub:type="footnote" id="n{i}">"#))
        .collect();
    let b = one(&format!("{open}<p>deep</p>{}", "</aside>".repeat(100)));
    assert!(format!("{:?}", b.blocks).contains("deep"));
    roundtrips(&b);
}

#[test]
fn linked_image_alone_is_figure() {
    let bytes = epub_with(
        "de",
        &[r#"<p><a href="https://example.org"><img src="pic.png"/></a></p>"#],
        &[("OEBPS/pic.png", PIXEL_PNG)],
    );
    let b = convert(bytes).expect("convert");
    assert!(
        matches!(b.blocks[0].block, Block::Figure { .. }),
        "{:?}",
        b.blocks
    );
}

#[test]
fn link_over_blocks_is_dropped_text_kept() {
    let b = one(r#"<a href="https://example.org"><p>one</p><p>two</p></a>"#);
    assert_eq!(paras(&b), ["one", "two"]);
    assert!(!format!("{:?}", b.blocks).contains("Link"));
}

#[test]
fn text_after_nested_list_becomes_paragraph() {
    let b = one("<ul><li>a<ul><li>b</li></ul>c</li><li>d</li></ul>");
    let got: Vec<_> = b
        .blocks
        .iter()
        .map(|n| match &n.block {
            Block::ListItem { depth, inlines, .. } => format!("item{depth}:{}", plain(inlines)),
            Block::Paragraph { inlines } => format!("p:{}", plain(inlines)),
            _ => "?".into(),
        })
        .collect();
    assert_eq!(got, ["item0:a", "item1:b", "p:c", "item0:d"]);
}

fn styled_book(css: &str, body: &str) -> flow_core::model::Book {
    let chapter = format!(
        r#"<?xml version="1.0"?><html xmlns="http://www.w3.org/1999/xhtml"><head><link rel="stylesheet" type="text/css" href="s/a.css"/></head><body>{body}</body></html>"#
    );
    let bytes = epub_raw(
        "xx",
        &[chapter.into_bytes()],
        &[("OEBPS/s/a.css", css.as_bytes())],
        zip::CompressionMethod::Deflated,
    );
    convert(bytes).expect("book")
}

const MONO_CSS: &str = r#"/* c */ p.Normal { font-family: "PT Serif", serif; }
p.listing-body, p.list-one { font-family: "Consol", monospace; margin-left: 2em }
span.command { font-family: Consolas , Courier New }"#;

#[test]
fn monospace_paragraph_classes_become_merged_code_block() {
    let b = styled_book(
        MONO_CSS,
        "<p class=\"Normal\">text</p>\
         <p class=\"listing-body\">void main() {</p>\
         <p class=\"listing-body\">&#160;&#160;x = 1; <strong>// c</strong></p>\
         <p class=\"Normal\">end</p>",
    );
    assert_eq!(b.blocks.len(), 3);
    match &b.blocks[1].block {
        Block::Code { lines } => assert_eq!(
            lines,
            &[
                "void main() {".to_string(),
                "\u{a0}\u{a0}x = 1; // c".to_string()
            ]
        ),
        other => panic!("{other:?}"),
    }
}

#[test]
fn monospace_span_class_becomes_inline_code() {
    let b = styled_book(
        MONO_CSS,
        "<p>see <span class=\"command\">foo()</span> now</p>",
    );
    match &b.blocks[0].block {
        Block::Paragraph { inlines } => {
            let code: Vec<&Inline> = inlines
                .iter()
                .filter(|i| matches!(i, Inline::Text { style, .. } if style.code))
                .collect();
            assert_eq!(code.len(), 1);
            assert_eq!(plain(inlines), "see foo() now");
        }
        other => panic!("{other:?}"),
    }
}

#[test]
fn non_monospace_classes_stay_paragraphs() {
    let b = styled_book(
        MONO_CSS,
        "<p class=\"Normal\">a</p><p class=\"other\">b</p>",
    );
    assert!(b
        .blocks
        .iter()
        .all(|n| matches!(n.block, Block::Paragraph { .. })));
}

#[test]
fn missing_stylesheet_is_ignored() {
    let chapter = r#"<html><head><link rel="stylesheet" href="nope.css"/></head><body><p class="x">a</p></body></html>"#;
    let bytes = epub_raw(
        "xx",
        &[chapter.as_bytes().to_vec()],
        &[],
        zip::CompressionMethod::Deflated,
    );
    assert_eq!(convert(bytes).expect("book").blocks.len(), 1);
}
