//! EPUB import: code recognised by a monospace class in the book's stylesheet.
#![allow(
    clippy::expect_used,
    clippy::unwrap_used,
    clippy::panic,
    clippy::unreachable,
    clippy::indexing_slicing
)]
mod common;

use common::epub::*;
use flow_core::model::{Block, Book, Inline, LinkTarget, ListMarker, Script, Style};
use zip::CompressionMethod;

const CSS_PATH: &str = "OEBPS/s/a.css";

const MONO_CSS: &str = r#"/* c */ p.Normal { font-family: "PT Serif", serif; }
p.listing-body, p.list-one, .m { font-family: "Consol", monospace; margin-left: 2em }
span.command { font-family: Consolas , Courier New }"#;

fn styled_epub(css: &[u8], body: &str, method: CompressionMethod) -> Vec<u8> {
    let chapter = format!(
        r#"<?xml version="1.0"?><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"><head><link rel="Stylesheet" type="text/css" href="s/a.css"/></head><body>{body}</body></html>"#
    );
    let extra = [(CSS_PATH, css), ("OEBPS/p.png", PIXEL_PNG)];
    epub_raw("xx", &[chapter.into_bytes()], &extra, method)
}

fn styled_book(css: &str, body: &str) -> Book {
    let bytes = styled_epub(css.as_bytes(), body, CompressionMethod::Deflated);
    convert(bytes).expect("book")
}

fn code(b: &Block) -> Vec<&str> {
    match b {
        Block::Code { lines } => lines.iter().map(String::as_str).collect(),
        other => panic!("not code: {other:?}"),
    }
}

fn all_paragraphs(b: &Book) -> bool {
    b.blocks
        .iter()
        .all(|n| matches!(n.block, Block::Paragraph { .. }))
}

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
    assert_eq!(
        code(&b.blocks[1].block),
        ["void main() {", "\u{a0}\u{a0}x = 1; // c"]
    );
}

#[test]
fn monospace_span_class_becomes_inline_code() {
    let b = styled_book(
        MONO_CSS,
        "<p>see <span class=\"command\">foo()</span> now</p>",
    );
    match &b.blocks[0].block {
        Block::Paragraph { inlines } => {
            let code = inlines
                .iter()
                .filter(|i| matches!(i, Inline::Text { style, .. } if style.code))
                .count();
            assert_eq!(code, 1);
            assert_eq!(plain(inlines), "see foo() now");
        }
        other => panic!("{other:?}"),
    }
}

#[test]
fn non_monospace_classes_stay_paragraphs() {
    let b = styled_book(
        MONO_CSS,
        "<p class=\"Normal\">a</p><p class=\"other\">b</p><p class=\"mm\">c</p>",
    );
    assert!(all_paragraphs(&b));
}

#[test]
fn missing_stylesheet_is_ignored() {
    let chapter = r#"<html><head><link rel="stylesheet" href="nope.css"/></head><body><p class="x">a</p></body></html>"#;
    let bytes = epub_raw(
        "xx",
        &[chapter.as_bytes().to_vec()],
        &[],
        CompressionMethod::Deflated,
    );
    assert_eq!(convert(bytes).expect("book").blocks.len(), 1);
}

#[test]
fn damaged_stylesheet_is_skipped_not_fatal() {
    let css = ".m { font-family: monospace } /* MARKER */";
    let mut bytes = styled_epub(
        css.as_bytes(),
        "<p class=\"m\">a</p>",
        CompressionMethod::Stored,
    );
    let at = bytes
        .windows(6)
        .position(|w| w == b"MARKER")
        .expect("stored css");
    bytes[at] = b'X'; // checksum no longer matches
    assert!(all_paragraphs(&convert(bytes).expect("book")));
}

#[test]
fn oversized_stylesheet_is_skipped() {
    let css = format!(".m {{ font-family: monospace }}{}", " ".repeat(2 << 20));
    assert!(all_paragraphs(&styled_book(&css, "<p class=\"m\">a</p>")));
}

#[test]
fn br_splits_lines_and_source_newlines_do_not() {
    let b = styled_book(
        MONO_CSS,
        "<p class=\"m\">line1<br/>line2<br/>\u{a0}\u{a0}line3<br/></p><p class=\"m\">a =\n\t\t   b;</p>",
    );
    assert_eq!(
        code(&b.blocks[0].block),
        ["line1", "line2", "\u{a0}\u{a0}line3", "a = b;"]
    );
}

#[test]
fn blank_lines_inside_a_listing_survive_but_not_around_it() {
    let b = styled_book(
        MONO_CSS,
        "<p class=\"m\"> </p><p class=\"m\">a</p><p class=\"m\"> </p><p class=\"m\"><br/></p>\
         <p class=\"m\">b</p><p class=\"m\"> </p><p>end</p>",
    );
    assert_eq!(b.blocks.len(), 2);
    assert_eq!(code(&b.blocks[0].block), ["a", "", "", "b"]);
}

#[test]
fn compound_and_descendant_selectors_are_ignored() {
    let css = "p.Normal.code { font-family: monospace } .aside p.Normal { font-family: monospace }";
    assert!(all_paragraphs(&styled_book(
        css,
        "<p class=\"Normal\">a</p><p class=\"code\">b</p>"
    )));
}

#[test]
fn only_real_monospace_fonts_count() {
    let css = ".a { font-family: 'Monotype Corsiva' } .b { font-family: Monomakh, serif }\
               .c { font-family: Georgia, serif, 'DejaVu Sans Mono' }";
    assert!(all_paragraphs(&styled_book(
        css,
        "<p class=\"a\">a</p><p class=\"b\">b</p><p class=\"c\">c</p>"
    )));
    let css = ".a { font-family: 'DejaVu Sans Mono', serif } .b { font-family: X, monospace }\
               .c { font-family: UbuntuMono !important }";
    for class in ["a", "b", "c"] {
        let b = styled_book(css, &format!("<p class=\"{class}\">x</p>"));
        assert_eq!(code(&b.blocks[0].block), ["x"], "{class}");
    }
}

#[test]
fn tables_figures_and_list_items_keep_their_structure() {
    let b = styled_book(
        MONO_CSS,
        "<table><tr><td><p class=\"m\">c</p></td></tr></table>\
         <ul><li><p class=\"m\">item</p></li></ul>\
         <figure><p class=\"m\">f</p></figure>",
    );
    assert!(matches!(b.blocks[0].block, Block::Table(_)));
    assert!(matches!(
        b.blocks[1].block,
        Block::ListItem {
            marker: ListMarker::Bullet,
            ..
        }
    ));
    assert!(!b
        .blocks
        .iter()
        .any(|n| matches!(n.block, Block::Code { .. })));
}

#[test]
fn listings_merge_inside_quotes_but_not_across_pre_or_div() {
    let b = styled_book(
        MONO_CSS,
        "<blockquote><p class=\"m\">q1</p><p class=\"m\">q2</p></blockquote>\
         <pre>one</pre><p class=\"m\">two</p>\
         <div><p class=\"m\">three</p></div><div><p class=\"m\">four</p></div>",
    );
    match &b.blocks[0].block {
        Block::Quote { blocks } => assert_eq!(code(&blocks[0].block), ["q1", "q2"]),
        other => panic!("{other:?}"),
    }
    let rest: Vec<Vec<&str>> = b.blocks[1..].iter().map(|n| code(&n.block)).collect();
    assert_eq!(rest, [["one"], ["two"], ["three"], ["four"]]);
}

#[test]
fn monospace_paragraph_with_link_or_image_stays_a_paragraph() {
    let b = styled_book(
        MONO_CSS,
        "<p class=\"m\">x<a epub:type=\"noteref\" href=\"#n\">1</a> y</p>\
         <p class=\"m\">see <a href=\"http://e.test/\">site</a></p>\
         <p class=\"m\"><a id=\"anchor\"></a>code</p>\
         <p class=\"m\">pic <img src=\"p.png\"/></p>\
         <aside epub:type=\"footnote\" id=\"n\"><p>note</p></aside>",
    );
    match &b.blocks[0].block {
        Block::Paragraph { inlines } => {
            assert!(inlines.iter().any(|i| matches!(i, Inline::NoteRef { .. })));
            assert!(matches!(&inlines[0], Inline::Text { style, .. } if style.code));
        }
        other => panic!("{other:?}"),
    }
    match &b.blocks[1].block {
        Block::Paragraph { inlines } => {
            assert!(inlines.iter().any(|i| matches!(i, Inline::Link { .. })));
        }
        other => panic!("{other:?}"),
    }
    assert_eq!(code(&b.blocks[2].block), ["code"]);
    match &b.blocks[3].block {
        Block::Paragraph { inlines } => {
            assert!(inlines.iter().any(|i| matches!(i, Inline::Image { .. })));
        }
        other => panic!("{other:?}"),
    }
}

/// The first run of the first block, which a demoted paragraph had buffered.
fn first_run(body: &str) -> (String, Style) {
    let b = styled_book(MONO_CSS, body);
    match &b.blocks[0].block {
        Block::Paragraph { inlines } => match &inlines[0] {
            Inline::Text { text, style } => (text.clone(), style.clone()),
            other => panic!("{other:?}"),
        },
        other => panic!("{other:?}"),
    }
}

#[test]
fn demoted_paragraph_does_not_take_the_style_around_the_link_or_image() {
    let plain_code = Style {
        code: true,
        bold: false,
        italic: false,
        script: Script::Normal,
    };
    for tail in [
        "<sup><a href=\"http://e.test/\">1</a></sup>",
        "<sub><a href=\"http://e.test/\">1</a></sub>",
        "<em><a href=\"http://e.test/\">x</a></em>",
        "<strong><img src=\"p.png\"/></strong>",
    ] {
        let (text, style) = first_run(&format!("<p class=\"m\">int x = 1;{tail}</p>"));
        assert_eq!(
            (text.as_str(), style),
            ("int x = 1;", plain_code.clone()),
            "{tail}"
        );
    }
}

#[test]
fn link_to_a_merged_listing_line_points_at_the_code_block() {
    let b = styled_book(
        MONO_CSS,
        "<p><a href=\"#second\">go</a></p><p class=\"m\">a</p>\
         <p class=\"m\" id=\"second\">b</p><p>after</p>",
    );
    match &b.blocks[0].block {
        Block::Paragraph { inlines } => assert!(
            matches!(
                &inlines[0],
                Inline::Link {
                    target: LinkTarget::Internal(1),
                    ..
                }
            ),
            "{inlines:?}"
        ),
        other => panic!("{other:?}"),
    }
}
