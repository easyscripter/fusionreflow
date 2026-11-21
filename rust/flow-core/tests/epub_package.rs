//! EPUB import: package, TOC, paths, progress and determinism.
#![allow(
    clippy::expect_used,
    clippy::unwrap_used,
    clippy::panic,
    clippy::unreachable,
    clippy::indexing_slicing
)]
mod common;

use common::epub::*;
use flow_core::codec::{decode, encode};
use flow_core::import::{
    CancelToken, Converter, EpubConverter, ImportError, Progress, SourceKind, Stage,
    EPUB_CONVERTER_VERSION,
};
use flow_core::model::{Block, ResourceId};
use sha2::{Digest, Sha256};
use std::io::Cursor;

#[test]
fn epub2_minimal_metadata() {
    let b = convert(pack("epub2-minimal")).expect("convert");
    assert_eq!(b.meta.title, "Тестовая книга");
    assert_eq!(b.meta.authors, ["A1", "A2"]);
    assert_eq!(b.meta.language.as_deref(), Some("ru"));
    assert_eq!(b.meta.cover, None);
}

#[test]
fn epub2_minimal_chapters_in_spine_order() {
    let b = convert(pack("epub2-minimal")).expect("convert");
    let kinds: Vec<_> = b
        .blocks
        .iter()
        .map(|n| match &n.block {
            Block::Heading { level, .. } => format!("h{level}"),
            Block::Paragraph { .. } => "p".into(),
            _ => "?".into(),
        })
        .collect();
    assert_eq!(kinds, ["h1", "p", "h1", "p"]);
    assert_eq!(text_of(&b.blocks[0].block), "Глава 1");
    assert_eq!(text_of(&b.blocks[2].block), "Глава 2");
    assert!(b.blocks.iter().all(|n| n.src.is_none()));
}

#[test]
fn epub2_ncx_toc() {
    let b = convert(pack("epub2-minimal")).expect("convert");
    let toc: Vec<_> = b
        .toc
        .iter()
        .map(|t| (t.level, t.title.as_str(), t.block))
        .collect();
    assert_eq!(toc, [(1, "Первая", 0), (1, "Вторая", 2)]);
}

#[test]
fn epub3_nav_toc_nested() {
    let b = convert(pack("epub3-nav")).expect("convert");
    let toc: Vec<_> = b
        .toc
        .iter()
        .map(|t| (t.level, t.title.as_str(), t.block))
        .collect();
    assert_eq!(
        toc,
        [
            (1, "Часть", 0),
            (2, "Раздел", 2),
            (3, "Подраздел", 4),
            (2, "Дитя потерянного", 6)
        ]
    );
}

#[test]
fn epub3_nav_preferred_over_ncx() {
    let b = convert(pack("epub3-nav")).expect("convert");
    assert!(b.toc.iter().all(|t| t.title != "NCX Title"));
    assert_eq!(b.toc[0].title, "Часть");
}

#[test]
fn toc_entry_with_missing_target_dropped() {
    let b = convert(pack("epub3-nav")).expect("convert");
    assert!(b.toc.iter().all(|t| t.title != "Потерянный"));
    assert!(b.toc.iter().any(|t| t.title == "Дитя потерянного"));
}

#[test]
fn cover_image_epub3_is_first_resource() {
    let b = convert(pack("epub3-images")).expect("convert");
    assert_eq!(b.meta.cover, Some(ResourceId(0)));
    assert_eq!(b.resources[0].mime, "image/png");
    assert_eq!(b.resources[0].data, PIXEL_PNG);
}

#[test]
fn cover_meta_epub2() {
    let b = convert(pack("epub2-cover-meta")).expect("convert");
    assert_eq!(b.meta.cover, Some(ResourceId(0)));
    assert_eq!(b.resources[0].mime, "image/jpeg");
}

#[test]
fn creator_roles_filtered() {
    let b = convert(pack("epub2-cover-meta")).expect("convert");
    assert_eq!(b.meta.authors, ["Author"]);
}

#[test]
fn percent_encoded_and_dotdot_paths() {
    let b = convert(pack("edge-paths")).expect("convert");
    let p = paras(&b);
    assert!(p.contains(&"space chapter".to_string()));
    assert!(p.contains(&"dotdot chapter".to_string()));
}

#[test]
fn case_insensitive_entry_fallback() {
    // `sub/../Sub/two.xhtml` resolves to `Sub/two.xhtml`; the entry is `sub/two.xhtml`
    let b = convert(pack("edge-paths")).expect("convert");
    assert!(paras(&b).contains(&"dotdot chapter".to_string()));
}

#[test]
fn missing_spine_item_skipped() {
    let mut events = Vec::new();
    let b = convert_events(pack("edge-paths"), &CancelToken::new(), &mut |p| {
        events.push(p)
    })
    .expect("convert");
    assert!(paras(&b).contains(&"last chapter".to_string()));
    assert_eq!(events.len(), 5);
    assert!(events
        .iter()
        .all(|e| e.total == 5 && e.stage == Stage::Pages));
}

#[test]
fn source_hash_is_sha256_of_bytes() {
    let bytes = pack("epub2-minimal");
    let expected = Sha256::digest(&bytes)
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect::<String>();
    let mut cur = Cursor::new(bytes);
    cur.set_position(17);
    let b = EpubConverter
        .convert(&mut cur, SourceKind::Epub, &mut |_| {}, &CancelToken::new())
        .expect("convert");
    assert_eq!(b.source_hash.len(), 64);
    assert_eq!(b.source_hash, expected);
}

#[test]
fn converter_version_and_format() {
    let b = convert(pack("epub2-minimal")).expect("convert");
    assert_eq!(b.format_version, 1);
    assert_eq!(b.converter_version, EPUB_CONVERTER_VERSION);
}

#[test]
fn progress_per_spine_item() {
    let mut ev = Vec::new();
    convert_events(
        epub_with("de", &["<p>a</p>", "<p>b</p>", "<p>c</p>"], &[]),
        &CancelToken::new(),
        &mut |p| ev.push(p),
    )
    .expect("convert");
    let want: Vec<_> = (1..=3)
        .map(|d| Progress {
            stage: Stage::Pages,
            done: d,
            total: 3,
        })
        .collect();
    assert_eq!(ev, want);
}

#[test]
fn cancel_between_chapters() {
    let token = CancelToken::new();
    let t2 = token.clone();
    let mut n = 0;
    let r = convert_events(
        epub_with("de", &["<p>a</p>", "<p>b</p>", "<p>c</p>"], &[]),
        &token,
        &mut |_| {
            n += 1;
            t2.cancel();
        },
    );
    assert_eq!(r, Err(ImportError::Cancelled));
    assert_eq!(n, 1);
}

#[test]
fn cancel_before_start() {
    let token = CancelToken::new();
    token.cancel();
    let mut n = 0;
    let r = convert_events(pack("epub2-minimal"), &token, &mut |_| n += 1);
    assert_eq!(r, Err(ImportError::Cancelled));
    assert_eq!(n, 0);
}

#[test]
fn encoded_book_roundtrips() {
    let b = content();
    assert_eq!(decode(&encode(&b).expect("encode")).expect("decode"), b);
}

#[test]
fn same_bytes_same_book() {
    assert_eq!(content(), content());
}

#[test]
fn manifest_media_type_of_shared_file_is_deterministic() {
    let opf = br#"<package><metadata/><manifest>
<item id="c0" href="c0.xhtml" media-type="application/xhtml+xml"/>
<item id="a" href="pic.png" media-type="image/png"/>
<item id="b" href="pic.png" media-type="text/plain"/>
</manifest><spine><itemref idref="c0"/></spine></package>"#;
    let chapter = xhtml(r#"<p>t</p><p><img src="pic.png"/></p>"#);
    for _ in 0..30 {
        let bytes = pack_files(&[
            ("META-INF/container.xml", common::epub::CONTAINER.as_bytes()),
            ("OEBPS/content.opf", opf),
            ("OEBPS/c0.xhtml", chapter.as_bytes()),
            ("OEBPS/pic.png", PIXEL_PNG),
        ]);
        let b = convert(bytes).expect("convert");
        assert_eq!(b.resources.len(), 1);
        assert_eq!(b.resources[0].mime, "image/png");
    }
}

/// A one-chapter EPUB whose OPF metadata block contains `meta` after the title.
fn epub_with_meta(meta: &str) -> Vec<u8> {
    let opf = format!(
        r#"<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>T</dc:title>{meta}</metadata><manifest><item id="c0" href="c0.xhtml" media-type="application/xhtml+xml"/></manifest><spine><itemref idref="c0"/></spine></package>"#
    );
    let chapter = xhtml("<p>x</p>");
    pack_files(&[
        ("META-INF/container.xml", CONTAINER.as_bytes()),
        ("OEBPS/content.opf", opf.as_bytes()),
        ("OEBPS/c0.xhtml", chapter.as_bytes()),
    ])
}

#[test]
fn reads_description() {
    let b = convert(epub_with_meta(
        "<dc:description>&lt;p&gt;X&lt;/p&gt;</dc:description>",
    ))
    .expect("convert");
    assert_eq!(b.meta.description.as_deref(), Some("X"));
}

#[test]
fn first_description_wins() {
    let b = convert(epub_with_meta(
        "<dc:description>one</dc:description><dc:description>two</dc:description>",
    ))
    .expect("convert");
    assert_eq!(b.meta.description.as_deref(), Some("one"));
}

#[test]
fn no_description_is_none() {
    let b = convert(epub_with_meta("")).expect("convert");
    assert_eq!(b.meta.description, None);
}

#[test]
fn description_with_child_elements_keeps_paragraphs() {
    let b = convert(epub_with_meta(
        "<dc:description><p>A</p><p>B</p>one<br/>two</dc:description>",
    ))
    .expect("convert");
    assert_eq!(b.meta.description.as_deref(), Some("A\n\nB\n\none\n\ntwo"));
}
