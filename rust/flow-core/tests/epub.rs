//! EPUB import, end to end (fixtures are synthetic).
#![allow(
    clippy::expect_used,
    clippy::unwrap_used,
    clippy::panic,
    clippy::unreachable,
    clippy::indexing_slicing
)]
mod common;

use common::epub::{
    convert, convert_events, epub_raw, epub_with, pack, pack_files, xhtml, PIXEL_PNG,
};
use flow_core::codec::{decode, encode};
use flow_core::import::{
    CancelToken, Converter, EpubConverter, ImportError, Progress, SourceKind, Stage,
    EPUB_CONVERTER_VERSION,
};
use flow_core::model::{Block, Book, Inline, LinkTarget, ListMarker, ResourceId, Script, Style};
use sha2::{Digest, Sha256};
use std::io::Cursor;

fn plain(inl: &[Inline]) -> String {
    inl.iter()
        .map(|i| match i {
            Inline::Text { text, .. } => text.replace('\u{ad}', ""),
            Inline::Link { inlines, .. } => plain(inlines),
            Inline::NoteRef { label, .. } => format!("[{label}]"),
            Inline::Image { .. } => "<img>".into(),
        })
        .collect()
}

fn text_of(b: &Block) -> String {
    match b {
        Block::Heading { inlines, .. }
        | Block::Paragraph { inlines }
        | Block::ListItem { inlines, .. } => plain(inlines),
        _ => String::new(),
    }
}

fn paras(b: &Book) -> Vec<String> {
    b.blocks
        .iter()
        .filter(|n| matches!(n.block, Block::Paragraph { .. }))
        .map(|n| text_of(&n.block))
        .collect()
}

fn find(b: &Book, f: impl Fn(&Block) -> bool) -> (usize, &Block) {
    b.blocks
        .iter()
        .enumerate()
        .find(|(_, n)| f(&n.block))
        .map(|(i, n)| (i, &n.block))
        .expect("block not found")
}

fn para_with<'a>(b: &'a Book, needle: &str) -> (usize, &'a [Inline]) {
    let (i, bl) = find(b, |bl| {
        matches!(bl, Block::Paragraph { .. }) && text_of(bl).contains(needle)
    });
    match bl {
        Block::Paragraph { inlines } => (i, inlines),
        _ => unreachable!(),
    }
}

fn one(body: &str) -> Book {
    convert(epub_with("de", &[body], &[])).expect("convert")
}

fn corrupted(r: Result<Book, ImportError>, text: &str) {
    match r {
        Err(ImportError::Corrupted(m)) => assert!(m.starts_with(text), "got: {m}"),
        other => panic!("expected Corrupted({text}), got {other:?}"),
    }
}

fn content() -> Book {
    convert(pack("epub3-content")).expect("convert")
}

fn norm(s: &str) -> String {
    s.replace('\u{ad}', "")
}

// ---- general -------------------------------------------------------------

#[test]
fn non_epub_kind_is_unsupported() {
    let mut events = 0;
    let r = EpubConverter.convert(
        &mut Cursor::new(Vec::new()),
        SourceKind::Fb2,
        &mut |_| events += 1,
        &CancelToken::new(),
    );
    assert!(matches!(r, Err(ImportError::Unsupported(SourceKind::Fb2))));
    assert_eq!(events, 0);
}

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

// ---- block conversion ----------------------------------------------------

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

// ---- images --------------------------------------------------------------

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

// ---- links ---------------------------------------------------------------

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

// ---- paths ---------------------------------------------------------------

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
fn malformed_chapter_keeps_prefix() {
    let b = convert(pack("edge-paths")).expect("convert");
    let p = paras(&b);
    assert!(p.contains(&"before break".to_string()));
    assert!(p.contains(&"last chapter".to_string()));
}

// ---- hyphenation ---------------------------------------------------------

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

// ---- identity, progress, cancel -----------------------------------------

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

// ---- errors --------------------------------------------------------------

#[test]
fn garbage_is_corrupted() {
    corrupted(
        convert(b"definitely not a zip file at all".to_vec()),
        "epub:",
    );
    corrupted(convert(Vec::new()), "epub:");
}

#[test]
fn truncated_zip_is_corrupted() {
    let bytes = pack("epub2-minimal");
    corrupted(convert(bytes[..bytes.len() * 6 / 10].to_vec()), "epub:");
}

const CONTAINER_OK: &str = r#"<container><rootfiles><rootfile full-path="o.opf" media-type="application/oebps-package+xml"/></rootfiles></container>"#;

#[test]
fn missing_container_is_corrupted() {
    corrupted(
        convert(pack_files(&[("a.txt", b"x")])),
        "epub: missing META-INF/container.xml",
    );
}

#[test]
fn missing_package_is_corrupted() {
    corrupted(
        convert(pack_files(&[("META-INF/container.xml", b"<container/>")])),
        "epub: missing package document",
    );
    corrupted(
        convert(pack_files(&[(
            "META-INF/container.xml",
            CONTAINER_OK.as_bytes(),
        )])),
        "epub: missing package document",
    );
}

#[test]
fn invalid_package_is_corrupted() {
    corrupted(
        convert(pack_files(&[
            ("META-INF/container.xml", CONTAINER_OK.as_bytes()),
            ("o.opf", b"<package><metadata></package>"),
        ])),
        "epub: invalid package document",
    );
}

#[test]
fn empty_spine_is_corrupted() {
    let opf = br#"<package><manifest/><spine/></package>"#;
    corrupted(
        convert(pack_files(&[
            ("META-INF/container.xml", CONTAINER_OK.as_bytes()),
            ("o.opf", opf),
        ])),
        "epub: no readable chapters",
    );
}

#[test]
fn no_content_is_corrupted() {
    corrupted(
        convert(epub_with("de", &["", "<p>  </p>"], &[])),
        "epub: no content",
    );
}

fn encryption(algorithm: &str, uri: &str) -> String {
    format!(
        r#"<encryption xmlns="urn:oasis:names:tc:opendocument:xmlns:container" xmlns:enc="http://www.w3.org/2001/04/xmlenc#"><enc:EncryptedData><enc:EncryptionMethod Algorithm="{algorithm}"/><enc:CipherData><enc:CipherReference URI="{uri}"/></enc:CipherData></enc:EncryptedData></encryption>"#
    )
}

#[test]
fn encrypted_chapter_rejected() {
    let enc = encryption(
        "http://www.w3.org/2001/04/xmlenc#aes128-cbc",
        "OEBPS/c0.xhtml",
    );
    corrupted(
        convert(epub_with(
            "de",
            &["<p>a</p>"],
            &[("META-INF/encryption.xml", enc.as_bytes())],
        )),
        "epub: encrypted (DRM)",
    );
}

#[test]
fn font_obfuscation_allowed() {
    let enc = encryption("http://www.idpf.org/2008/embedding", "OEBPS/font.otf");
    let b = convert(epub_with(
        "de",
        &["<p>a</p>"],
        &[("META-INF/encryption.xml", enc.as_bytes())],
    ));
    assert!(b.is_ok());
}

#[test]
fn oversized_entry_rejected() {
    let mut big = xhtml("<p>x</p>").into_bytes();
    big.resize(64 * 1024 * 1024 + 1, b' ');
    let bytes = epub_raw("de", &[big], &[], zip::CompressionMethod::Stored);
    corrupted(convert(bytes), "epub: entry too large");
}

#[test]
fn deep_nesting_no_stack_overflow() {
    let body = format!("{}<p>deep</p>{}", "<div>".repeat(300), "</div>".repeat(300));
    let b = one(&body);
    assert_eq!(paras(&b), ["deep"]);
}

#[test]
fn utf16_chapter_decoded() {
    let doc = xhtml("<p>привет</p>");
    let mut bytes = vec![0xFF, 0xFE];
    for u in doc.encode_utf16() {
        bytes.extend_from_slice(&u.to_le_bytes());
    }
    let b = convert(epub_raw(
        "de",
        &[bytes],
        &[],
        zip::CompressionMethod::Deflated,
    ))
    .expect("convert");
    assert_eq!(paras(&b), ["привет"]);
}
