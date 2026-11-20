//! EPUB import: corrupted, protected and oversized input.
#![allow(
    clippy::expect_used,
    clippy::unwrap_used,
    clippy::panic,
    clippy::unreachable,
    clippy::indexing_slicing
)]
mod common;

use common::epub::*;
use flow_core::import::{CancelToken, Converter, EpubConverter, ImportError, SourceKind};
use std::io::Cursor;

const CONTAINER_OK: &str = r#"<container><rootfiles><rootfile full-path="o.opf" media-type="application/oebps-package+xml"/></rootfiles></container>"#;

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
fn malformed_chapter_keeps_prefix() {
    let b = convert(pack("edge-paths")).expect("convert");
    let p = paras(&b);
    assert!(p.contains(&"before break".to_string()));
    assert!(p.contains(&"last chapter".to_string()));
}

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
