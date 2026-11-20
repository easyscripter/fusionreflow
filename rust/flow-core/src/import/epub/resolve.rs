//! Second pass: turns drafts into model blocks. Links become block indices,
//! note references pair with footnotes, the contents list is mapped, and
//! text gets soft hyphens.
use super::draft::{DBlock, DInline, LinkKind, Top};
use super::path::Target;
use super::toc::Draft;
use super::xml::collapse;
use crate::model::{Block, BlockNode, Inline, LinkTarget, TocEntry};
use crate::text::Hyphenator;
use std::collections::{HashMap, HashSet};

/// Maps an archive path to the real entry name.
pub(super) type Canonical<'a> = &'a dyn Fn(&str) -> Option<String>;

struct Ctx<'a> {
    anchors: HashMap<String, usize>,
    first: HashMap<String, usize>,
    footnotes: HashSet<String>,
    canonical: Canonical<'a>,
    hyphenator: Option<&'a Hyphenator>,
}

fn collect_footnotes(b: &DBlock, out: &mut HashSet<String>) {
    match b {
        DBlock::Footnote { id, blocks } => {
            out.insert(id.clone());
            blocks.iter().for_each(|b| collect_footnotes(b, out));
        }
        DBlock::Quote(blocks) => blocks.iter().for_each(|b| collect_footnotes(b, out)),
        _ => {}
    }
}

fn raw_text(v: &[DInline]) -> String {
    v.iter()
        .map(|i| match i {
            DInline::Text { text, .. } => text.clone(),
            DInline::Link { inlines, .. } => raw_text(inlines),
            DInline::Image(_) => String::new(),
        })
        .collect()
}

fn plain_text(v: &[DInline]) -> String {
    collapse(&raw_text(v))
}

impl Ctx<'_> {
    /// Block index for a target: the anchor, or the chapter's first block when there is no fragment.
    fn lookup(&self, t: &Target) -> Option<(String, usize)> {
        let key = (self.canonical)(&t.path)?;
        let idx = match &t.fragment {
            Some(f) => *self.anchors.get(&format!("{key}#{f}"))?,
            None => *self.first.get(&key)?,
        };
        Some((key, idx))
    }

    fn inlines(&self, src: Vec<DInline>, out: &mut Vec<Inline>) {
        for i in src {
            match i {
                DInline::Text { text, style } => {
                    let text = match self.hyphenator {
                        Some(h) if !style.code => h.hyphenate(&text),
                        _ => text,
                    };
                    out.push(Inline::Text { text, style });
                }
                DInline::Image(res) => out.push(Inline::Image {
                    res,
                    height_em: 1.0,
                }),
                DInline::Link {
                    kind: LinkKind::External(url),
                    inlines,
                    ..
                } => {
                    let mut inner = Vec::new();
                    self.inlines(inlines, &mut inner);
                    out.push(Inline::Link {
                        target: LinkTarget::External(url),
                        inlines: inner,
                    });
                }
                DInline::Link {
                    kind: LinkKind::Internal(t),
                    noteref,
                    inlines,
                } => {
                    let Some((key, idx)) = self.lookup(&t) else {
                        self.inlines(inlines, out); // broken link: keep the text
                        continue;
                    };
                    let note_id = t.fragment.as_ref().map(|f| format!("{key}#{f}"));
                    match note_id {
                        Some(id) if noteref && self.footnotes.contains(&id) => {
                            out.push(Inline::NoteRef {
                                id,
                                label: plain_text(&inlines),
                            });
                        }
                        _ => {
                            let mut inner = Vec::new();
                            self.inlines(inlines, &mut inner);
                            out.push(Inline::Link {
                                target: LinkTarget::Internal(idx),
                                inlines: inner,
                            });
                        }
                    }
                }
            }
        }
    }

    fn inl(&self, src: Vec<DInline>) -> Vec<Inline> {
        let mut out = Vec::new();
        self.inlines(src, &mut out);
        out
    }

    fn nodes(&self, src: Vec<DBlock>) -> Vec<BlockNode> {
        src.into_iter().map(|b| self.node(b)).collect()
    }

    fn node(&self, b: DBlock) -> BlockNode {
        let block = match b {
            DBlock::Heading { level, inlines } => Block::Heading {
                level,
                inlines: self.inl(inlines),
            },
            DBlock::Paragraph(inlines) => Block::Paragraph {
                inlines: self.inl(inlines),
            },
            DBlock::ListItem {
                marker,
                depth,
                inlines,
            } => Block::ListItem {
                marker,
                depth,
                inlines: self.inl(inlines),
            },
            DBlock::Quote(blocks) => Block::Quote {
                blocks: self.nodes(blocks),
            },
            DBlock::Code(lines) => Block::Code { lines },
            DBlock::Figure { image, caption } => Block::Figure {
                image,
                caption: self.inl(caption),
            },
            DBlock::Table(rows) => Block::Table(crate::model::Table {
                rows: rows
                    .into_iter()
                    .map(|r| r.into_iter().map(|c| self.inl(c)).collect())
                    .collect(),
            }),
            DBlock::Footnote { id, blocks } => Block::Footnote {
                id,
                blocks: self.nodes(blocks),
            },
            DBlock::Separator => Block::Separator,
        };
        BlockNode { block, src: None }
    }
}

/// Resolved book content.
pub(super) struct Resolved {
    pub blocks: Vec<BlockNode>,
    pub toc: Vec<TocEntry>,
}

/// Builds the final blocks and contents list from per-chapter drafts.
pub(super) fn resolve(
    chapters: Vec<(String, Vec<Top>)>,
    toc: &[Draft],
    canonical: Canonical<'_>,
    hyphenator: Option<&Hyphenator>,
) -> Resolved {
    let mut ctx = Ctx {
        anchors: HashMap::new(),
        first: HashMap::new(),
        footnotes: HashSet::new(),
        canonical,
        hyphenator,
    };
    let mut idx = 0usize;
    for (path, tops) in &chapters {
        for (n, top) in tops.iter().enumerate() {
            if n == 0 {
                ctx.first.entry(path.clone()).or_insert(idx);
            }
            for id in &top.anchors {
                ctx.anchors.entry(format!("{path}#{id}")).or_insert(idx);
            }
            collect_footnotes(&top.block, &mut ctx.footnotes);
            idx += 1;
        }
    }
    let blocks = chapters
        .into_iter()
        .flat_map(|(_, tops)| tops)
        .map(|t| ctx.node(t.block))
        .collect();
    let toc = toc
        .iter()
        .filter(|d| !d.title.is_empty())
        .filter_map(|d| {
            let (_, block) = ctx.lookup(d.target.as_ref()?)?;
            Some(TocEntry {
                level: u8::try_from(d.level).unwrap_or(u8::MAX),
                title: d.title.clone(),
                block,
            })
        })
        .collect();
    Resolved { blocks, toc }
}
