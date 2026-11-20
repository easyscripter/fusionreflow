//! One XHTML chapter → draft blocks (links still symbolic, images already
//! turned into resources).
mod assemble;
mod start;

use self::start::VOID;
use super::draft::{DBlock, DInline, Images, LinkKind, Top};
use super::xml::{attr, end_name, event_text, name, reader};
use crate::model::{ListMarker, ResourceId, Script, Style};
use quick_xml::events::{BytesStart, Event};

/// Nesting deeper than this is read as if the extra elements were transparent.
pub(super) const MAX_DEPTH: usize = 256;

#[derive(Clone, Copy, PartialEq)]
enum Open {
    None,
    Para,
    Heading(u8),
    Item(ListMarker, u8),
    Cell,
    Caption,
}

enum Kind {
    Plain,
    Skip,
    Svg,
    Bold,
    Italic,
    Code,
    Sup,
    Sub,
    Link(usize),
    Block,
    Heading,
    List { ordered: bool, next: u32 },
    Li,
    Quote,
    Pre,
    Footnote,
    Table,
    NestedTable,
    Tr,
    Cell,
    Figure,
    Caption,
}

struct Frame {
    name: String,
    kind: Kind,
}

enum ContainerKind {
    Quote,
    Footnote(String),
}

struct Container {
    kind: ContainerKind,
    blocks: Vec<DBlock>,
}

struct LinkFrame {
    kind: LinkKind,
    noteref: bool,
    inlines: Vec<DInline>,
}

#[derive(Default)]
struct Figure {
    image: Option<ResourceId>,
    caption: Vec<DInline>,
}

#[derive(Default)]
struct Table {
    rows: Vec<Vec<Vec<DInline>>>,
    row: Option<Vec<Vec<DInline>>>,
}

#[derive(Default)]
struct Counts {
    bold: usize,
    italic: usize,
    code: usize,
    sup: usize,
    sub: usize,
}

struct Builder<'a> {
    chapter: &'a str,
    images: &'a mut dyn Images,
    frames: Vec<Frame>,
    skip: usize,
    svg: usize,
    table_nest: usize,
    counts: Counts,
    open: Open,
    acc: Vec<DInline>,
    links: Vec<LinkFrame>,
    pre: Option<String>,
    containers: Vec<Container>,
    tops: Vec<Top>,
    ids: Vec<String>,
    table: Option<Table>,
    fig: Option<Figure>,
}

/// Parses a chapter. Malformed XML ends the chapter but keeps what was read.
pub(super) fn parse_chapter(xml: &str, chapter: &str, images: &mut dyn Images) -> Vec<Top> {
    let mut r = reader(xml, false);
    let mut b = Builder::new(chapter, images);
    loop {
        match r.read_event() {
            Ok(Event::Start(e)) => {
                b.start(&e);
            }
            Ok(Event::Empty(e)) => {
                if b.start(&e) {
                    b.pop_frame();
                }
            }
            Ok(Event::End(e)) => b.end(&end_name(&e)),
            Ok(Event::Eof) | Err(_) => break,
            Ok(ev) => {
                if let Some(t) = event_text(&ev) {
                    b.text(&t);
                }
            }
        }
    }
    b.finish()
}

impl<'a> Builder<'a> {
    pub(super) fn new(chapter: &'a str, images: &'a mut dyn Images) -> Self {
        Self {
            chapter,
            images,
            frames: Vec::new(),
            skip: 0,
            svg: 0,
            table_nest: 0,
            counts: Counts::default(),
            open: Open::None,
            acc: Vec::new(),
            links: Vec::new(),
            pre: None,
            containers: Vec::new(),
            tops: Vec::new(),
            ids: Vec::new(),
            table: None,
            fig: None,
        }
    }

    pub(super) fn finish(mut self) -> Vec<Top> {
        while !self.frames.is_empty() {
            self.pop_frame();
        }
        self.flush();
        self.tops
    }

    // ---- events ----------------------------------------------------------

    /// Handles a start tag; returns `true` when a frame was pushed.
    pub(super) fn start(&mut self, e: &BytesStart<'_>) -> bool {
        let n = name(e);
        if self.skip > 0 {
            return self.push(n, Kind::Plain);
        }
        if self.svg > 0 {
            if n == "image" {
                self.image(attr(e, "href"));
            }
            return self.push(n, Kind::Plain);
        }
        self.ids.extend(attr(e, "id"));
        if n == "a" {
            self.ids.extend(attr(e, "name"));
        }
        if VOID.contains(&n.as_str()) {
            self.void(&n, e);
            return false;
        }
        if self.frames.len() >= MAX_DEPTH {
            return self.push(n, Kind::Plain);
        }
        let kind = self.kind_for(&n, e);
        self.push(n, kind)
    }

    pub(super) fn push(&mut self, n: String, kind: Kind) -> bool {
        match kind {
            Kind::Skip => self.skip += 1,
            Kind::Svg => self.svg += 1,
            Kind::Bold => self.counts.bold += 1,
            Kind::Italic => self.counts.italic += 1,
            Kind::Code => self.counts.code += 1,
            Kind::Sup => self.counts.sup += 1,
            Kind::Sub => self.counts.sub += 1,
            Kind::NestedTable => self.table_nest += 1,
            _ => {}
        }
        self.frames.push(Frame { name: n, kind });
        true
    }

    pub(super) fn end(&mut self, n: &str) {
        let Some(pos) = self.frames.iter().rposition(|f| f.name == n) else {
            return;
        };
        while self.frames.len() > pos {
            self.pop_frame();
        }
    }

    pub(super) fn text(&mut self, s: &str) {
        if self.skip > 0 || self.svg > 0 {
            return;
        }
        if let Some(buf) = self.pre.as_mut() {
            buf.push_str(s);
            return;
        }
        let mut prev_space = self.last_is_space();
        let mut out = String::with_capacity(s.len());
        for ch in s.chars() {
            if matches!(ch, ' ' | '\t' | '\r' | '\n') {
                if !prev_space {
                    out.push(' ');
                    prev_space = true;
                }
            } else {
                out.push(ch);
                prev_space = false;
            }
        }
        if out.trim_matches(' ').is_empty() && (self.open == Open::None || out.is_empty()) {
            return;
        }
        if self.open == Open::None {
            self.open = Open::Para;
        }
        self.push_text(out);
    }
}
