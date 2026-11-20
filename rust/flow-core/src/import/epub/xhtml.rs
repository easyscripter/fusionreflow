//! One XHTML chapter → draft blocks (links still symbolic, images already
//! turned into resources).
use super::path::{resolve, Target};
use super::xml::{attr, end_name, event_text, name, reader};
use crate::model::{ListMarker, ResourceId, Script, Style};
use quick_xml::events::{BytesStart, Event};

/// Nesting deeper than this is read as if the extra elements were transparent.
pub(super) const MAX_DEPTH: usize = 256;

const VOID: [&str; 12] = [
    "br", "img", "hr", "meta", "link", "input", "col", "wbr", "area", "base", "source", "embed",
];
const SKIP: [&str; 8] = [
    "head", "script", "style", "template", "rt", "rp", "object", "noscript",
];
const BLOCKISH: [&str; 24] = [
    "p", "div", "section", "article", "aside", "nav", "header", "footer", "main", "body", "html",
    "dl", "dt", "dd", "address", "form", "fieldset", "center", "details", "summary", "hgroup",
    "caption", "thead", "tfoot",
];
const NOTE_TYPES: [&str; 5] = [
    "footnote",
    "endnote",
    "rearnote",
    "doc-footnote",
    "doc-endnote",
];

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

fn scheme_of(href: &str) -> Option<&str> {
    let (s, _) = href.split_once(':')?;
    let ok = !s.is_empty()
        && s.chars()
            .all(|c| c.is_ascii_alphanumeric() || matches!(c, '+' | '-' | '.'));
    ok.then_some(s)
}

fn has_token(value: Option<String>, tokens: &[&str]) -> bool {
    value.is_some_and(|v| v.split_whitespace().any(|t| tokens.contains(&t)))
}

fn ends_with_space(v: &[DInline]) -> Option<bool> {
    match v.last()? {
        DInline::Text { text, .. } => Some(text.ends_with([' ', '\n'])),
        DInline::Link { inlines, .. } => ends_with_space(inlines).or(Some(false)),
        DInline::Image(_) => Some(false),
    }
}

fn trim(v: &mut Vec<DInline>) {
    let cut = |t: &mut String, front: bool| {
        let s = if front {
            t.trim_start_matches([' ', '\n'])
        } else {
            t.trim_end_matches([' ', '\n'])
        };
        *t = s.to_owned();
        t.is_empty()
    };
    while let Some(DInline::Text { text, .. }) = v.first_mut() {
        if cut(text, true) {
            v.remove(0);
        } else {
            break;
        }
    }
    while let Some(DInline::Text { text, .. }) = v.last_mut() {
        if cut(text, false) {
            v.pop();
        } else {
            break;
        }
    }
}

impl<'a> Builder<'a> {
    fn new(chapter: &'a str, images: &'a mut dyn Images) -> Self {
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

    fn finish(mut self) -> Vec<Top> {
        while !self.frames.is_empty() {
            self.pop_frame();
        }
        self.flush();
        self.tops
    }

    // ---- events ----------------------------------------------------------

    /// Handles a start tag; returns `true` when a frame was pushed.
    fn start(&mut self, e: &BytesStart<'_>) -> bool {
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

    fn push(&mut self, n: String, kind: Kind) -> bool {
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

    fn end(&mut self, n: &str) {
        let Some(pos) = self.frames.iter().rposition(|f| f.name == n) else {
            return;
        };
        while self.frames.len() > pos {
            self.pop_frame();
        }
    }

    fn text(&mut self, s: &str) {
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

    // ---- start-tag dispatch ---------------------------------------------

    fn kind_for(&mut self, n: &str, e: &BytesStart<'_>) -> Kind {
        if SKIP.contains(&n) {
            return Kind::Skip;
        }
        if matches!(n, "aside" | "div" | "section" | "li" | "p") && self.footnote_start(e) {
            return Kind::Footnote;
        }
        match n {
            "svg" => Kind::Svg,
            "b" | "strong" => Kind::Bold,
            "i" | "em" | "cite" | "dfn" | "var" => Kind::Italic,
            "code" | "tt" | "kbd" | "samp" => Kind::Code,
            "sup" => Kind::Sup,
            "sub" => Kind::Sub,
            "a" => self.link_start(e),
            "h1" | "h2" | "h3" | "h4" | "h5" | "h6" => self.heading_start(n),
            "ul" | "ol" => self.list_start(n == "ol", e),
            "li" => self.li_start(),
            "blockquote" => {
                self.flush();
                self.containers.push(Container {
                    kind: ContainerKind::Quote,
                    blocks: Vec::new(),
                });
                Kind::Quote
            }
            "pre" if self.pre.is_none() => {
                self.flush();
                self.pre = Some(String::new());
                Kind::Pre
            }
            "table" => self.table_start(),
            "tr" | "td" | "th" => self.cell_start(n),
            "figure" if self.fig.is_none() => {
                self.flush();
                self.fig = Some(Figure::default());
                Kind::Figure
            }
            "figcaption" if self.fig.is_some() => {
                self.flush();
                self.open = Open::Caption;
                Kind::Caption
            }
            _ if BLOCKISH.contains(&n) => {
                self.boundary();
                Kind::Block
            }
            _ => Kind::Plain,
        }
    }

    fn footnote_start(&mut self, e: &BytesStart<'_>) -> bool {
        let Some(id) = attr(e, "id") else {
            return false;
        };
        if !(has_token(attr(e, "type"), &NOTE_TYPES) || has_token(attr(e, "role"), &NOTE_TYPES)) {
            return false;
        }
        self.flush();
        let id = format!("{}#{id}", self.chapter);
        self.containers.push(Container {
            kind: ContainerKind::Footnote(id),
            blocks: Vec::new(),
        });
        true
    }

    fn link_start(&mut self, e: &BytesStart<'_>) -> Kind {
        let Some(kind) = attr(e, "href").and_then(|h| self.link_kind(&h)) else {
            return Kind::Plain;
        };
        let noteref = has_token(attr(e, "type"), &["noteref"])
            || has_token(attr(e, "role"), &["doc-noteref"]);
        self.links.push(LinkFrame {
            kind,
            noteref,
            inlines: Vec::new(),
        });
        Kind::Link(self.links.len() - 1)
    }

    fn link_kind(&self, href: &str) -> Option<LinkKind> {
        let h = href.trim();
        if h.is_empty() {
            return None;
        }
        if let Some(scheme) = scheme_of(h) {
            let s = scheme.to_ascii_lowercase();
            return matches!(s.as_str(), "http" | "https" | "mailto")
                .then(|| LinkKind::External(h.to_owned()));
        }
        resolve(self.chapter, h).map(LinkKind::Internal)
    }

    fn heading_start(&mut self, n: &str) -> Kind {
        if self.joined() {
            self.space();
            return Kind::Plain;
        }
        self.flush();
        let level = n
            .chars()
            .nth(1)
            .and_then(|c| c.to_digit(10))
            .unwrap_or(1)
            .min(4);
        self.open = Open::Heading(u8::try_from(level).unwrap_or(4));
        Kind::Heading
    }

    fn list_start(&mut self, ordered: bool, e: &BytesStart<'_>) -> Kind {
        self.list_boundary();
        let next = attr(e, "start")
            .and_then(|s| s.trim().parse().ok())
            .unwrap_or(1);
        Kind::List { ordered, next }
    }

    fn li_start(&mut self) -> Kind {
        if matches!(self.open, Open::Cell | Open::Caption) {
            self.space();
            return Kind::Plain;
        }
        self.flush();
        let depth = self
            .frames
            .iter()
            .filter(|f| matches!(f.kind, Kind::List { .. }))
            .count();
        let marker = match self
            .frames
            .iter_mut()
            .rev()
            .find_map(|f| match &mut f.kind {
                Kind::List { ordered, next } => Some((*ordered, next)),
                _ => None,
            }) {
            Some((true, next)) => {
                let m = ListMarker::Number(*next);
                *next = next.saturating_add(1);
                m
            }
            _ => ListMarker::Bullet,
        };
        let depth = u8::try_from(depth.saturating_sub(1)).unwrap_or(u8::MAX);
        self.open = Open::Item(marker, depth);
        Kind::Li
    }

    fn table_start(&mut self) -> Kind {
        if self.table.is_some() {
            self.space();
            return Kind::NestedTable;
        }
        self.flush();
        self.table = Some(Table::default());
        Kind::Table
    }

    fn cell_start(&mut self, n: &str) -> Kind {
        if self.table.is_none() || self.table_nest > 0 {
            self.space();
            return Kind::Plain;
        }
        self.finish_cell();
        if n == "tr" {
            self.finish_row();
        }
        if let Some(t) = self.table.as_mut() {
            t.row.get_or_insert_with(Vec::new);
        }
        if n == "tr" {
            return Kind::Tr;
        }
        self.flush();
        self.open = Open::Cell;
        Kind::Cell
    }

    fn void(&mut self, n: &str, e: &BytesStart<'_>) {
        match n {
            "br" => {
                if let Some(p) = self.pre.as_mut() {
                    p.push('\n');
                } else if self.open != Open::None {
                    self.push_text("\n".into());
                }
            }
            "img" => self.image(attr(e, "src")),
            "hr" => {
                self.flush();
                self.push_block(DBlock::Separator);
            }
            _ => {}
        }
    }

    fn image(&mut self, src: Option<String>) {
        let Some(id) = src.and_then(|s| self.images.load(self.chapter, &s)) else {
            return;
        };
        if let Some(f) = self.fig.as_mut() {
            if self.open != Open::Caption && f.image.is_none() {
                f.image = Some(id);
                return;
            }
        }
        if self.open == Open::None {
            self.open = Open::Para;
        }
        self.target().push(DInline::Image(id));
    }

    // ---- end-tag actions ----------------------------------------------------

    fn pop_frame(&mut self) {
        let Some(Frame { kind, .. }) = self.frames.pop() else {
            return;
        };
        match kind {
            Kind::Plain => {}
            Kind::Skip => self.skip = self.skip.saturating_sub(1),
            Kind::Svg => self.svg = self.svg.saturating_sub(1),
            Kind::Bold => self.counts.bold = self.counts.bold.saturating_sub(1),
            Kind::Italic => self.counts.italic = self.counts.italic.saturating_sub(1),
            Kind::Code => self.counts.code = self.counts.code.saturating_sub(1),
            Kind::Sup => self.counts.sup = self.counts.sup.saturating_sub(1),
            Kind::Sub => self.counts.sub = self.counts.sub.saturating_sub(1),
            Kind::Link(i) => self.close_links(i),
            Kind::Block => self.boundary(),
            Kind::Heading => {
                if matches!(self.open, Open::Heading(_)) {
                    self.flush();
                }
            }
            Kind::List { .. } => self.list_boundary(),
            Kind::Li => {
                if matches!(self.open, Open::Item(..)) {
                    self.flush();
                }
            }
            Kind::Quote | Kind::Footnote => {
                self.flush();
                if let Some(c) = self.containers.pop() {
                    let block = match c.kind {
                        ContainerKind::Quote => DBlock::Quote(c.blocks),
                        ContainerKind::Footnote(id) => DBlock::Footnote {
                            id,
                            blocks: c.blocks,
                        },
                    };
                    let empty = matches!(&block, DBlock::Quote(b) | DBlock::Footnote { blocks: b, .. } if b.is_empty());
                    if !empty {
                        self.push_block(block);
                    }
                }
            }
            Kind::Pre => self.finish_pre(),
            Kind::NestedTable => {
                self.table_nest = self.table_nest.saturating_sub(1);
                self.space();
            }
            Kind::Table => {
                self.finish_cell();
                self.finish_row();
                if let Some(t) = self.table.take() {
                    if !t.rows.is_empty() {
                        self.push_block(DBlock::Table(t.rows));
                    }
                }
            }
            Kind::Tr => {
                self.finish_cell();
                self.finish_row();
            }
            Kind::Cell => self.finish_cell(),
            Kind::Figure => {
                self.flush();
                if let Some(f) = self.fig.take() {
                    match f.image {
                        Some(image) => self.push_block(DBlock::Figure {
                            image,
                            caption: f.caption,
                        }),
                        None if !f.caption.is_empty() => {
                            self.push_block(DBlock::Paragraph(f.caption))
                        }
                        None => {}
                    }
                }
            }
            Kind::Caption => {
                if self.open == Open::Caption {
                    self.flush();
                }
            }
        }
    }

    // ---- block assembly ---------------------------------------------------

    fn joined(&self) -> bool {
        matches!(self.open, Open::Item(..) | Open::Cell | Open::Caption)
    }

    /// Between blocks: flush, or just separate with a space inside list items, cells and captions.
    fn boundary(&mut self) {
        if self.joined() {
            self.space();
        } else {
            self.flush();
        }
    }

    /// Lists end the current item, but inside a cell or caption they only add a space.
    fn list_boundary(&mut self) {
        if matches!(self.open, Open::Cell | Open::Caption) {
            self.space();
        } else {
            self.flush();
        }
    }

    fn finish_cell(&mut self) {
        if self.open == Open::Cell {
            self.flush();
        }
    }

    fn finish_row(&mut self) {
        if let Some(t) = self.table.as_mut() {
            if let Some(row) = t.row.take() {
                if !row.is_empty() {
                    t.rows.push(row);
                }
            }
        }
    }

    fn finish_pre(&mut self) {
        let Some(buf) = self.pre.take() else { return };
        let buf = buf.replace("\r\n", "\n");
        let mut lines: Vec<String> = buf
            .strip_prefix('\n')
            .unwrap_or(&buf)
            .split('\n')
            .map(str::to_owned)
            .collect();
        while lines.last().is_some_and(String::is_empty) {
            lines.pop();
        }
        if !lines.is_empty() {
            self.push_block(DBlock::Code(lines));
        }
    }

    fn flush(&mut self) {
        self.close_links(0);
        let mut inl = std::mem::take(&mut self.acc);
        let open = std::mem::replace(&mut self.open, Open::None);
        trim(&mut inl);
        match open {
            Open::None => {}
            Open::Cell => {
                if let Some(t) = self.table.as_mut() {
                    t.row.get_or_insert_with(Vec::new).push(inl);
                }
            }
            Open::Caption => {
                if let Some(f) = self.fig.as_mut() {
                    f.caption = inl;
                }
            }
            _ if inl.is_empty() => {}
            Open::Para => match inl.as_slice() {
                [DInline::Image(image)] => {
                    let image = *image;
                    self.push_block(DBlock::Figure {
                        image,
                        caption: Vec::new(),
                    });
                }
                _ => self.push_block(DBlock::Paragraph(inl)),
            },
            Open::Heading(level) => self.push_block(DBlock::Heading {
                level,
                inlines: inl,
            }),
            Open::Item(marker, depth) => {
                self.push_block(DBlock::ListItem {
                    marker,
                    depth,
                    inlines: inl,
                });
            }
        }
    }

    fn push_block(&mut self, block: DBlock) {
        match self.containers.last_mut() {
            Some(c) => c.blocks.push(block),
            None => {
                let anchors = std::mem::take(&mut self.ids);
                self.tops.push(Top { block, anchors });
            }
        }
    }

    // ---- inline assembly --------------------------------------------------

    fn target(&mut self) -> &mut Vec<DInline> {
        match self.links.last_mut() {
            Some(l) => &mut l.inlines,
            None => &mut self.acc,
        }
    }

    fn last_is_space(&self) -> bool {
        self.links
            .iter()
            .rev()
            .find_map(|l| ends_with_space(&l.inlines))
            .or_else(|| ends_with_space(&self.acc))
            .unwrap_or(true)
    }

    fn space(&mut self) {
        if self.open != Open::None && !self.last_is_space() {
            self.push_text(" ".into());
        }
    }

    fn style(&self) -> Style {
        let c = &self.counts;
        Style {
            bold: c.bold > 0,
            italic: c.italic > 0,
            code: c.code > 0,
            script: if c.sup > 0 {
                Script::Sup
            } else if c.sub > 0 {
                Script::Sub
            } else {
                Script::Normal
            },
        }
    }

    fn push_text(&mut self, text: String) {
        let style = self.style();
        let target = self.target();
        if let Some(DInline::Text {
            text: last,
            style: s,
        }) = target.last_mut()
        {
            if *s == style {
                last.push_str(&text);
                return;
            }
        }
        target.push(DInline::Text { text, style });
    }

    /// Closes link frames from index `from` upward, moving their content into the parent.
    fn close_links(&mut self, from: usize) {
        while self.links.len() > from {
            let Some(l) = self.links.pop() else { break };
            if l.inlines.is_empty() {
                continue;
            }
            self.target().push(DInline::Link {
                kind: l.kind,
                noteref: l.noteref,
                inlines: l.inlines,
            });
        }
    }
}
