//! Block format v1: the book representation exchanged between importers,
//! the PDF converter and the renderer.
//!
//! The v1 encoding is frozen: a new optional field must use `#[serde(default)]` and
//! `skip_serializing_if` (books without it then encode byte for byte as before);
//! renames, removals or variant changes require bumping `FORMAT_VERSION` and
//! regenerating `tests/fixtures/book_v1.cbor` with
//! `cargo test -p flow-core -- --ignored regenerate_golden_fixture`.

mod block;
mod book;
mod inline;
mod resource;

pub use block::{Block, BlockNode, ListMarker, SourceRef, Table};
pub use book::{Book, Meta, TocEntry};
pub use inline::{Inline, LinkTarget, Script, Style};
pub use resource::{Resource, ResourceId};
