//! Builds EPUB archives for tests: from fixture folders or from in-memory files.
use flow_core::import::{CancelToken, Converter, EpubConverter, ImportError, Progress, SourceKind};
use flow_core::model::Book;
use std::io::{Cursor, Write};
use std::path::{Path, PathBuf};
use zip::write::SimpleFileOptions;
use zip::{CompressionMethod, ZipWriter};

/// The 1×1 PNG shared by the fixtures.
pub const PIXEL_PNG: &[u8] = include_bytes!("../fixtures/epub/pixel.png");

fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/epub")
}

fn collect(dir: &Path, rel: &str, out: &mut Vec<String>) {
    for e in std::fs::read_dir(dir).expect("read fixture dir") {
        let e = e.expect("dir entry");
        let name = format!("{rel}{}", e.file_name().to_string_lossy());
        if e.path().is_dir() {
            collect(&e.path(), &format!("{name}/"), out);
        } else {
            out.push(name);
        }
    }
}

/// Packs `fixtures/epub/<dir>` into an EPUB. Paths listed in `_images.txt`
/// get the shared `pixel.png` bytes.
pub fn pack(dir: &str) -> Vec<u8> {
    let base = root().join(dir);
    let mut names = Vec::new();
    collect(&base, "", &mut names);
    let images: Vec<String> = std::fs::read_to_string(base.join("_images.txt"))
        .map(|s| s.lines().map(str::to_owned).collect())
        .unwrap_or_default();
    names.extend(images.iter().cloned());
    names.sort();
    let files: Vec<(String, Vec<u8>)> = names
        .into_iter()
        .filter(|n| n != "_images.txt")
        .map(|n| {
            let data = if images.contains(&n) {
                PIXEL_PNG.to_vec()
            } else {
                std::fs::read(base.join(&n)).expect("read fixture")
            };
            (n, data)
        })
        .collect();
    let refs: Vec<(&str, &[u8])> = files
        .iter()
        .map(|(n, d)| (n.as_str(), d.as_slice()))
        .collect();
    pack_files(&refs)
}

/// Packs in-memory files; `mimetype` goes first, stored; the rest are deflated.
pub fn pack_files(files: &[(&str, &[u8])]) -> Vec<u8> {
    pack_with(files, CompressionMethod::Deflated)
}

/// Like [`pack_files`] with a chosen method for non-`mimetype` entries.
pub fn pack_with(files: &[(&str, &[u8])], method: CompressionMethod) -> Vec<u8> {
    let mut z = ZipWriter::new(Cursor::new(Vec::new()));
    let stored = SimpleFileOptions::default().compression_method(CompressionMethod::Stored);
    z.start_file("mimetype", stored).expect("start");
    z.write_all(b"application/epub+zip").expect("write");
    for (name, data) in files.iter().filter(|(n, _)| *n != "mimetype") {
        z.start_file(
            *name,
            SimpleFileOptions::default().compression_method(method),
        )
        .expect("start");
        z.write_all(data).expect("write");
    }
    z.finish().expect("finish").into_inner()
}

pub const CONTAINER: &str = r#"<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>"#;

/// Wraps a body fragment into a chapter document.
pub fn xhtml(body: &str) -> String {
    format!(
        r#"<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"><head><title>t</title></head><body>{body}</body></html>"#
    )
}

/// A one-chapter-per-body EPUB with language `lang`; `extra` files are added.
pub fn epub_with(lang: &str, bodies: &[&str], extra: &[(&str, &[u8])]) -> Vec<u8> {
    let chapters: Vec<Vec<u8>> = bodies.iter().map(|b| xhtml(b).into_bytes()).collect();
    epub_raw(lang, &chapters, extra, CompressionMethod::Deflated)
}

/// Like [`epub_with`] but chapters are whole files (bytes) and the method is chosen.
pub fn epub_raw(
    lang: &str,
    chapters: &[Vec<u8>],
    extra: &[(&str, &[u8])],
    method: CompressionMethod,
) -> Vec<u8> {
    let items: String = (0..chapters.len())
        .map(|i| {
            format!(r#"<item id="c{i}" href="c{i}.xhtml" media-type="application/xhtml+xml"/>"#)
        })
        .collect();
    let spine: String = (0..chapters.len())
        .map(|i| format!(r#"<itemref idref="c{i}"/>"#))
        .collect();
    let opf = format!(
        r#"<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>T</dc:title><dc:language>{lang}</dc:language></metadata><manifest>{items}</manifest><spine>{spine}</spine></package>"#
    );
    let names: Vec<String> = (0..chapters.len())
        .map(|i| format!("OEBPS/c{i}.xhtml"))
        .collect();
    let mut files: Vec<(&str, &[u8])> = vec![
        ("META-INF/container.xml", CONTAINER.as_bytes()),
        ("OEBPS/content.opf", opf.as_bytes()),
    ];
    for (n, c) in names.iter().zip(chapters.iter()) {
        files.push((n, c));
    }
    files.extend_from_slice(extra);
    pack_with(&files, method)
}

/// Converts EPUB bytes, collecting progress events.
pub fn convert(bytes: Vec<u8>) -> Result<Book, ImportError> {
    convert_events(bytes, &CancelToken::new(), &mut |_| {})
}

/// Converts with a cancel token and a progress callback.
pub fn convert_events(
    bytes: Vec<u8>,
    cancel: &CancelToken,
    on: &mut dyn FnMut(Progress),
) -> Result<Book, ImportError> {
    EpubConverter.convert(&mut Cursor::new(bytes), SourceKind::Epub, on, cancel)
}
