//! Library catalog API exposed to Dart: bibliographic data of an encoded book.

pub use flow_core::model::{
    Block, BlockNode, Book, Inline, LinkTarget, ListMarker, Meta, Resource, ResourceId, Script,
    SourceRef, Style, Table, TocEntry,
};
pub use flow_core::FormatError;
use flutter_rust_bridge::frb;

#[frb(mirror(FormatError))]
pub enum _FormatError {
    UnsupportedFormatVersion(u32),
    Corrupt(String),
    Encode(String),
}

#[frb(mirror(Book))]
pub struct _Book {
    pub format_version: u32,
    pub converter_version: String,
    pub source_hash: String,
    pub meta: Meta,
    pub toc: Vec<TocEntry>,
    pub blocks: Vec<BlockNode>,
    pub resources: Vec<Resource>,
}

#[frb(mirror(Meta))]
pub struct _Meta {
    pub title: String,
    pub authors: Vec<String>,
    pub language: Option<String>,
    pub cover: Option<ResourceId>,
    pub description: Option<String>,
}

#[frb(mirror(TocEntry))]
pub struct _TocEntry {
    pub level: u8,
    pub title: String,
    pub block: usize,
}

#[frb(mirror(BlockNode))]
pub struct _BlockNode {
    pub block: Block,
    pub src: Option<SourceRef>,
}

#[frb(mirror(Block))]
pub enum _Block {
    Heading {
        level: u8,
        inlines: Vec<Inline>,
    },
    Paragraph {
        inlines: Vec<Inline>,
    },
    ListItem {
        marker: ListMarker,
        depth: u8,
        inlines: Vec<Inline>,
    },
    Quote {
        blocks: Vec<BlockNode>,
    },
    Code {
        lines: Vec<String>,
    },
    Figure {
        image: ResourceId,
        caption: Vec<Inline>,
    },
    Formula {
        image: ResourceId,
    },
    Table(Table),
    Footnote {
        id: String,
        blocks: Vec<BlockNode>,
    },
    Separator,
    FixedPage {
        image: ResourceId,
    },
}

#[frb(mirror(ListMarker))]
pub enum _ListMarker {
    Bullet,
    Number(u32),
}

#[frb(mirror(Table))]
pub struct _Table {
    pub rows: Vec<Vec<Vec<Inline>>>,
}

#[frb(mirror(SourceRef))]
pub struct _SourceRef {
    pub page: u32,
    pub rect: [f32; 4],
}

#[frb(mirror(Inline))]
pub enum _Inline {
    Text {
        text: String,
        style: Style,
    },
    Link {
        target: LinkTarget,
        inlines: Vec<Inline>,
    },
    NoteRef {
        id: String,
        label: String,
    },
    Image {
        res: ResourceId,
        height_em: f32,
    },
}

#[frb(mirror(Style))]
pub struct _Style {
    pub bold: bool,
    pub italic: bool,
    pub code: bool,
    pub script: Script,
}

#[frb(mirror(Script))]
pub enum _Script {
    Normal,
    Sup,
    Sub,
}

#[frb(mirror(LinkTarget))]
pub enum _LinkTarget {
    Internal(usize),
    External(String),
}

#[frb(mirror(ResourceId))]
pub struct _ResourceId(pub u32);

#[frb(mirror(Resource))]
pub struct _Resource {
    pub id: ResourceId,
    pub mime: String,
    pub data: Vec<u8>,
}

/// Bibliographic data of an encoded book, for the library catalog.
pub struct BookMeta {
    pub title: String,
    pub authors: Vec<String>,
    pub language: Option<String>,
    /// Plain-text annotation, paragraphs separated by "\n\n".
    pub description: Option<String>,
    pub source_hash: String,
    pub converter_version: String,
}

/// Decodes CBOR `bytes` (`flow_core::encode`) and returns its catalog data.
/// Errors: the `flow_core::decode` error as is (bad CBOR, unsupported `format_version`).
pub fn book_meta(bytes: Vec<u8>) -> Result<BookMeta, FormatError> {
    let book = flow_core::decode(&bytes)?;
    Ok(BookMeta {
        title: book.meta.title,
        authors: book.meta.authors,
        language: book.meta.language,
        description: book.meta.description,
        source_hash: book.source_hash,
        converter_version: book.converter_version,
    })
}

/// Decodes CBOR `bytes` and returns the whole book for the reader.
/// Errors: the `flow_core::decode` error as is.
pub fn book_content(bytes: Vec<u8>) -> Result<Book, FormatError> {
    flow_core::decode(&bytes)
}

#[cfg(test)]
mod tests {
    use super::*;

    const FIXTURE: &[u8] = include_bytes!("../../../flow-core/tests/fixtures/book_v1.cbor");

    // Expected values are `sample_book()` from `flow-core/tests/model.rs`, which
    // wrote `book_v1.cbor`; that helper is not reachable from this crate.
    #[test]
    fn book_meta_reads_fixture() {
        let meta = book_meta(FIXTURE.to_vec()).unwrap();
        assert_eq!(meta.title, "Title");
        assert_eq!(meta.authors, vec!["A", "B"]);
        assert_eq!(meta.language.as_deref(), Some("ru"));
        assert_eq!(meta.source_hash, "ab".repeat(32));
        assert_eq!(meta.converter_version, "0.1.0");
        assert_eq!(meta.description, None);
    }

    #[test]
    fn book_meta_reads_description() {
        let mut book = flow_core::decode(FIXTURE).unwrap();
        book.meta.description = Some("D".into());
        let bytes = flow_core::encode(&book).unwrap();
        assert_eq!(book_meta(bytes).unwrap().description.as_deref(), Some("D"));
    }

    #[test]
    fn book_meta_rejects_garbage() {
        assert!(matches!(
            book_meta(vec![0xFF, 0x00]),
            Err(FormatError::Corrupt(_))
        ));
    }

    #[test]
    fn book_content_reads_fixture() {
        let expected = flow_core::decode(FIXTURE).unwrap();
        let book = book_content(FIXTURE.to_vec()).unwrap();
        assert_eq!(book.meta, expected.meta);
        assert_eq!(book.toc, expected.toc);
        assert_eq!(book.blocks.len(), expected.blocks.len());
        assert_eq!(book.resources.len(), expected.resources.len());
    }

    #[test]
    fn book_content_rejects_garbage() {
        assert!(matches!(
            book_content(vec![0xFF, 0x00]),
            Err(FormatError::Corrupt(_))
        ));
    }

    #[test]
    fn book_content_rejects_empty() {
        assert!(matches!(book_content(vec![]), Err(FormatError::Corrupt(_))));
    }

    #[test]
    fn book_meta_rejects_empty() {
        assert!(matches!(book_meta(vec![]), Err(FormatError::Corrupt(_))));
    }
}
