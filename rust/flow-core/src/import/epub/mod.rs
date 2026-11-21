//! EPUB 2/3 importer: zip → package document → chapters → blocks v1.
//!
//! Order of work: hash the source, open the archive, read the package
//! (metadata, manifest, spine), reject DRM, convert spine chapters one by one
//! (progress + cancel between chapters), then resolve links, contents and
//! hyphenation in a second pass.
mod archive;
mod css;
mod description;
mod draft;
mod entities;
mod package;
mod path;
mod resolve;
mod toc;
mod xhtml;
mod xml;

use super::{CancelToken, Converter, ImportError, Progress, ReadSeek, SourceKind, Stage};
use crate::model::{Book, Meta, Resource, ResourceId};
use crate::text::Hyphenator;
use archive::{Archive, ArchiveError, Limits};
use package::Package;
use sha2::{Digest, Sha256};
use std::collections::{HashMap, HashSet};
use std::io::SeekFrom;

/// Converter version stored in imported books.
pub const EPUB_CONVERTER_VERSION: &str = concat!("epub/", env!("CARGO_PKG_VERSION"));

const NCX_MEDIA_TYPE: &str = "application/x-dtbncx+xml";

/// Imports EPUB 2 / EPUB 3 into blocks v1.
pub struct EpubConverter;

fn corrupted(msg: impl Into<String>) -> ImportError {
    ImportError::Corrupted(msg.into())
}

fn archive_error(e: ArchiveError) -> ImportError {
    corrupted(match e {
        ArchiveError::NotZip(m) => format!("epub: not a zip archive: {m}"),
        ArchiveError::TooManyEntries => "epub: too many entries".into(),
        ArchiveError::Missing => "epub: missing entry".into(),
        ArchiveError::EntryTooLarge => "epub: entry too large".into(),
        ArchiveError::TotalTooLarge => "epub: too large".into(),
        ArchiveError::Damaged(m) => format!("epub: damaged entry: {m}"),
    })
}

/// Reads an entry; `Ok(None)` when it is not in the archive.
fn read_entry(a: &mut Archive<'_>, path: &str) -> Result<Option<Vec<u8>>, ImportError> {
    match a.read(path) {
        Ok(b) => Ok(Some(b)),
        Err(ArchiveError::Missing) => Ok(None),
        Err(e) => Err(archive_error(e)),
    }
}

/// Monospace classes of the stylesheets a chapter links (each file read once).
fn mono_for(
    a: &mut Archive<'_>,
    cache: &mut HashMap<String, HashSet<String>>,
    chapter: &str,
    xml: &str,
) -> Result<HashSet<String>, ImportError> {
    let mut all = HashSet::new();
    for href in css::stylesheet_hrefs(xml) {
        let Some(path) =
            path::resolve(chapter, &href).and_then(|t| a.canonical(&t.path).map(str::to_owned))
        else {
            continue;
        };
        if !cache.contains_key(&path) {
            let classes = read_entry(a, &path)?
                .map(|b| css::mono_classes(&xml::decode_bytes(&b)))
                .unwrap_or_default();
            cache.insert(path.clone(), classes);
        }
        all.extend(cache[&path].iter().cloned());
    }
    Ok(all)
}

fn hash_source(src: &mut dyn ReadSeek) -> Result<String, ImportError> {
    let io = |e: std::io::Error| corrupted(format!("epub: cannot read source: {e}"));
    src.seek(SeekFrom::Start(0)).map_err(io)?;
    let mut hasher = Sha256::new();
    let mut buf = vec![0u8; 64 * 1024];
    loop {
        let n = src.read(&mut buf).map_err(io)?;
        let Some(chunk) = buf.get(..n).filter(|c| !c.is_empty()) else {
            break;
        };
        hasher.update(chunk);
    }
    src.seek(SeekFrom::Start(0)).map_err(io)?;
    Ok(hasher
        .finalize()
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect())
}

fn mime_by_extension(name: &str) -> Option<&'static str> {
    let ext = name.rsplit_once('.')?.1.to_ascii_lowercase();
    Some(match ext.as_str() {
        "png" => "image/png",
        "jpg" | "jpeg" => "image/jpeg",
        "gif" => "image/gif",
        "webp" => "image/webp",
        "svg" => "image/svg+xml",
        _ => return None,
    })
}

/// Stores images as resources, one per archive entry, in order of first use.
struct Loader<'a, 'b> {
    archive: &'a mut Archive<'b>,
    media: HashMap<String, String>,
    resources: Vec<Resource>,
    by_entry: HashMap<String, Option<ResourceId>>,
    fatal: Option<ImportError>,
}

impl Loader<'_, '_> {
    fn load_entry(&mut self, name: &str) -> Option<ResourceId> {
        if let Some(r) = self.by_entry.get(name) {
            return *r;
        }
        let r = self.read_image(name);
        self.by_entry.insert(name.to_owned(), r);
        r
    }

    fn read_image(&mut self, name: &str) -> Option<ResourceId> {
        let mime = self
            .media
            .get(name)
            .map(String::as_str)
            .or_else(|| mime_by_extension(name))?
            .to_owned();
        if !mime.starts_with("image/") {
            return None;
        }
        let data = match self.archive.read(name) {
            Ok(d) => d,
            Err(ArchiveError::TotalTooLarge) => {
                self.fatal = Some(archive_error(ArchiveError::TotalTooLarge));
                return None;
            }
            Err(_) => return None, // a broken picture must not break the book
        };
        let id = ResourceId(u32::try_from(self.resources.len()).ok()?);
        self.resources.push(Resource { id, mime, data });
        Some(id)
    }
}

impl draft::Images for Loader<'_, '_> {
    fn load(&mut self, chapter: &str, src: &str) -> Option<ResourceId> {
        let target = path::resolve(chapter, src)?;
        let name = self.archive.canonical(&target.path)?.to_owned();
        self.load_entry(&name)
    }
}

fn hyphenation_applies(language: Option<&str>) -> bool {
    language.is_none_or(|l| {
        let l = l.to_lowercase();
        l.starts_with("ru") || l.starts_with("en")
    })
}

/// Contents drafts: the EPUB 3 `nav`, else the NCX; empty when neither works.
fn read_toc(a: &mut Archive<'_>, pkg: &Package) -> Result<Vec<toc::Draft>, ImportError> {
    let item_path = |id: &str| pkg.manifest.get(id).and_then(|i| i.path.clone());
    let nav = pkg
        .order
        .iter()
        .find(|id| pkg.manifest.get(*id).is_some_and(|i| i.has_property("nav")))
        .and_then(|id| item_path(id));
    if let Some(p) = nav {
        if let Some(bytes) = read_entry(a, &p)? {
            let drafts = toc::parse_nav(&xml::decode_bytes(&bytes), &p);
            if !drafts.is_empty() {
                return Ok(drafts);
            }
        }
    }
    let ncx = pkg.spine_toc.as_deref().and_then(item_path).or_else(|| {
        pkg.order
            .iter()
            .find(|id| {
                pkg.manifest
                    .get(*id)
                    .is_some_and(|i| i.media_type == NCX_MEDIA_TYPE)
            })
            .and_then(|id| item_path(id))
    });
    let Some(p) = ncx else { return Ok(Vec::new()) };
    Ok(read_entry(a, &p)?
        .map(|b| toc::parse_ncx(&xml::decode_bytes(&b), &p))
        .unwrap_or_default())
}

/// Spine chapter paths (`None` for items that cannot be read as documents).
fn spine_paths(pkg: &Package) -> Vec<Option<String>> {
    pkg.spine
        .iter()
        .map(|id| {
            let item = pkg.manifest.get(id)?;
            let kind = item.media_type.split('/').next().unwrap_or_default();
            if matches!(kind, "image" | "audio" | "video") {
                return None;
            }
            item.path.clone()
        })
        .collect()
}

fn reject_drm(a: &mut Archive<'_>, spine: &[Option<String>]) -> Result<(), ImportError> {
    let Some(bytes) = read_entry(a, "META-INF/encryption.xml")? else {
        return Ok(());
    };
    let canon = |p: &str| {
        a.canonical(p)
            .map_or_else(|| p.to_lowercase(), str::to_owned)
    };
    let encrypted: HashSet<String> = package::encrypted_paths(&xml::decode_bytes(&bytes))
        .iter()
        .map(|p| canon(p))
        .collect();
    let hit = spine
        .iter()
        .flatten()
        .any(|p| encrypted.contains(&canon(p)));
    if hit {
        return Err(corrupted("epub: encrypted (DRM)"));
    }
    Ok(())
}

fn read_package(a: &mut Archive<'_>) -> Result<(Package, String), ImportError> {
    let container = read_entry(a, "META-INF/container.xml")?
        .ok_or_else(|| corrupted("epub: missing META-INF/container.xml"))?;
    let missing = || corrupted("epub: missing package document");
    let opf_path = package::parse_container(&xml::decode_bytes(&container))
        .and_then(|p| path::resolve("", &p))
        .and_then(|t| a.canonical(&t.path).map(str::to_owned))
        .ok_or_else(missing)?;
    let opf = read_entry(a, &opf_path)?.ok_or_else(missing)?;
    let pkg = package::parse_opf(&xml::decode_bytes(&opf), &opf_path)
        .map_err(|e| corrupted(format!("epub: invalid package document: {e}")))?;
    Ok((pkg, opf_path))
}

impl Converter for EpubConverter {
    fn convert(
        &self,
        src: &mut dyn ReadSeek,
        kind: SourceKind,
        progress: &mut dyn FnMut(Progress),
        cancel: &CancelToken,
    ) -> Result<Book, ImportError> {
        self.convert_with(src, kind, progress, cancel, Limits::DEFAULT)
    }
}

impl EpubConverter {
    /// [`Converter::convert`] with explicit size limits (small ones in tests).
    fn convert_with(
        &self,
        src: &mut dyn ReadSeek,
        kind: SourceKind,
        progress: &mut dyn FnMut(Progress),
        cancel: &CancelToken,
        limits: Limits,
    ) -> Result<Book, ImportError> {
        if kind != SourceKind::Epub {
            return Err(ImportError::Unsupported(kind));
        }
        if cancel.is_cancelled() {
            return Err(ImportError::Cancelled);
        }
        let source_hash = hash_source(src)?;
        let mut archive = Archive::open(src, limits).map_err(archive_error)?;
        let (pkg, _) = read_package(&mut archive)?;
        let spine = spine_paths(&pkg);
        reject_drm(&mut archive, &spine)?;
        if spine.is_empty() {
            return Err(corrupted("epub: no readable chapters"));
        }

        // In manifest order, the first entry for a file wins (never hash order).
        let mut media: HashMap<String, String> = HashMap::new();
        for item in pkg.order.iter().filter_map(|id| pkg.manifest.get(id)) {
            if let Some(name) = item.path.as_deref().and_then(|p| archive.canonical(p)) {
                media
                    .entry(name.to_owned())
                    .or_insert_with(|| item.media_type.clone());
            }
        }
        let mut loader = Loader {
            archive: &mut archive,
            media,
            resources: Vec::new(),
            by_entry: HashMap::new(),
            fatal: None,
        };
        let cover = pkg
            .cover_id()
            .and_then(|id| pkg.manifest.get(id))
            .and_then(|i| i.path.as_deref())
            .and_then(|p| loader.archive.canonical(p).map(str::to_owned))
            .and_then(|name| loader.load_entry(&name));

        let total = u32::try_from(spine.len()).unwrap_or(u32::MAX);
        let mut chapters: Vec<(String, Vec<draft::Top>)> = Vec::new();
        let mut css_cache: HashMap<String, HashSet<String>> = HashMap::new();
        for (i, item) in spine.iter().enumerate() {
            if cancel.is_cancelled() {
                return Err(ImportError::Cancelled);
            }
            let name = item
                .as_deref()
                .and_then(|p| loader.archive.canonical(p))
                .map(str::to_owned);
            if let Some(name) = name {
                if let Some(bytes) = read_entry(loader.archive, &name)? {
                    let text = xml::decode_bytes(&bytes);
                    let mono = mono_for(loader.archive, &mut css_cache, &name, &text)?;
                    let tops = xhtml::parse_chapter(&text, &name, &mono, &mut loader);
                    chapters.push((name, tops));
                }
            }
            if let Some(e) = loader.fatal.take() {
                return Err(e);
            }
            progress(Progress {
                stage: Stage::Pages,
                done: u32::try_from(i + 1).unwrap_or(u32::MAX),
                total,
            });
        }
        if cancel.is_cancelled() {
            return Err(ImportError::Cancelled);
        }
        if chapters.is_empty() {
            return Err(corrupted("epub: no readable chapters"));
        }
        if chapters.iter().all(|(_, t)| t.is_empty()) {
            return Err(corrupted("epub: no content"));
        }

        let drafts = read_toc(loader.archive, &pkg)?;
        let resources = std::mem::take(&mut loader.resources);
        let language = pkg.language.clone();
        let hyphenator = if hyphenation_applies(language.as_deref()) {
            Some(Hyphenator::new().map_err(|e| corrupted(format!("hyphenation dictionary: {e}")))?)
        } else {
            None
        };
        let canonical = |p: &str| archive.canonical(p).map(str::to_owned);
        let resolved = resolve::resolve(chapters, &drafts, &canonical, hyphenator.as_ref());
        Ok(Book {
            format_version: crate::FORMAT_VERSION,
            converter_version: EPUB_CONVERTER_VERSION.to_owned(),
            source_hash,
            meta: Meta {
                title: pkg.title,
                authors: pkg.authors,
                language,
                cover,
                description: pkg.description,
            },
            toc: resolved.toc,
            blocks: resolved.blocks,
            resources,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::{Cursor, Write};
    use zip::write::SimpleFileOptions;

    const CONTAINER: &str =
        r#"<container><rootfiles><rootfile full-path="o.opf"/></rootfiles></container>"#;
    const OPF: &str = r#"<package><manifest><item id="c" href="c.xhtml" media-type="application/xhtml+xml"/></manifest><spine><itemref idref="c"/></spine></package>"#;
    const CHAPTER: &str = r#"<html><body><p>t</p><p><img src="p.png"/></p></body></html>"#;

    fn zip_of(files: &[(&str, &[u8])]) -> Vec<u8> {
        let mut z = zip::ZipWriter::new(Cursor::new(Vec::new()));
        for (n, d) in files {
            z.start_file(*n, SimpleFileOptions::default())
                .expect("start");
            z.write_all(d).expect("write");
        }
        z.finish().expect("finish").into_inner()
    }

    fn book_files(image: &[u8]) -> Vec<(&str, &[u8])> {
        vec![
            ("META-INF/container.xml", CONTAINER.as_bytes()),
            ("o.opf", OPF.as_bytes()),
            ("c.xhtml", CHAPTER.as_bytes()),
            ("p.png", image),
        ]
    }

    fn run(bytes: Vec<u8>, limits: Limits) -> Result<Book, ImportError> {
        EpubConverter.convert_with(
            &mut Cursor::new(bytes),
            SourceKind::Epub,
            &mut |_| {},
            &CancelToken::new(),
            limits,
        )
    }

    #[test]
    fn too_many_entries_is_reported() {
        let limits = Limits {
            entries: 3,
            ..Limits::DEFAULT
        };
        let r = run(zip_of(&book_files(b"png")), limits);
        assert_eq!(r.err(), Some(corrupted("epub: too many entries")));
    }

    #[test]
    fn total_limit_stops_an_image_flood() {
        let image = vec![7u8; 1000];
        let text: u64 = [CONTAINER.len(), OPF.len(), CHAPTER.len()]
            .iter()
            .map(|n| *n as u64)
            .sum();
        let limits = Limits {
            total: text + 10,
            ..Limits::DEFAULT
        };
        let r = run(zip_of(&book_files(&image)), limits);
        assert_eq!(r.err(), Some(corrupted("epub: too large")));
        // the same book fits when the budget is generous
        assert!(run(zip_of(&book_files(&image)), Limits::DEFAULT).is_ok());
    }

    #[test]
    fn oversized_image_is_dropped_not_fatal() {
        let image = vec![7u8; 1000];
        let limits = Limits {
            entry: 500,
            ..Limits::DEFAULT
        };
        let b = run(zip_of(&book_files(&image)), limits).expect("book");
        assert!(b.resources.is_empty());
    }
}
