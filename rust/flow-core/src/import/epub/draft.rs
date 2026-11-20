//! Draft types shared by the chapter parser and the second pass (`resolve`).

use super::path::Target;
use crate::model::{ListMarker, ResourceId, Style};

/// Where a link points.
#[derive(Debug, Clone)]
pub(super) enum LinkKind {
    External(String),
    Internal(Target),
}

/// Inline content before links are resolved.
#[derive(Debug, Clone)]
pub(super) enum DInline {
    Text {
        text: String,
        style: Style,
    },
    Link {
        kind: LinkKind,
        noteref: bool,
        inlines: Vec<DInline>,
    },
    Image(ResourceId),
}

/// Block content before links are resolved.
#[derive(Debug)]
pub(super) enum DBlock {
    Heading {
        level: u8,
        inlines: Vec<DInline>,
    },
    Paragraph(Vec<DInline>),
    ListItem {
        marker: ListMarker,
        depth: u8,
        inlines: Vec<DInline>,
    },
    Quote(Vec<DBlock>),
    Code(Vec<String>),
    Figure {
        image: ResourceId,
        caption: Vec<DInline>,
    },
    Table(Vec<Vec<Vec<DInline>>>),
    Footnote {
        id: String,
        blocks: Vec<DBlock>,
    },
    Separator,
}

/// A top-level block and the element ids that point at it.
#[derive(Debug)]
pub(super) struct Top {
    pub block: DBlock,
    pub anchors: Vec<String>,
}

/// Turns `src` (as written in `chapter`) into a stored resource, if possible.
pub(super) trait Images {
    fn load(&mut self, chapter: &str, src: &str) -> Option<ResourceId>;
}
