//! End tags, block assembly and inline assembly.

use super::*;

pub(super) fn ends_with_space(v: &[DInline]) -> Option<bool> {
    match v.last()? {
        DInline::Text { text, .. } => Some(text.ends_with([' ', '\n'])),
        DInline::Link { inlines, .. } => ends_with_space(inlines).or(Some(false)),
        DInline::Image(_) => Some(false),
    }
}

/// The image when it is all there is (a link around it does not count).
pub(super) fn lone_image(v: &[DInline]) -> Option<ResourceId> {
    match v {
        [DInline::Image(id)] => Some(*id),
        [DInline::Link { inlines, .. }] => lone_image(inlines),
        _ => None,
    }
}

pub(super) fn trim(v: &mut Vec<DInline>) {
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

impl Builder<'_> {
    // ---- end-tag actions ----------------------------------------------------

    pub(super) fn pop_frame(&mut self) {
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

    pub(super) fn joined(&self) -> bool {
        matches!(self.open, Open::Item(..) | Open::Cell | Open::Caption)
    }

    /// Between blocks: flush, or just separate with a space inside list items, cells and captions.
    pub(super) fn boundary(&mut self) {
        if self.joined() {
            self.space();
        } else {
            self.flush();
        }
    }

    /// Lists end the current item, but inside a cell or caption they only add a space.
    pub(super) fn list_boundary(&mut self) {
        if matches!(self.open, Open::Cell | Open::Caption) {
            self.space();
        } else {
            self.flush();
        }
    }

    pub(super) fn finish_cell(&mut self) {
        if self.open == Open::Cell {
            self.flush();
        }
    }

    pub(super) fn finish_row(&mut self) {
        if let Some(t) = self.table.as_mut() {
            if let Some(row) = t.row.take() {
                if !row.is_empty() {
                    t.rows.push(row);
                }
            }
        }
    }

    pub(super) fn finish_pre(&mut self) {
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

    pub(super) fn flush(&mut self) {
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
            Open::Para => match lone_image(&inl) {
                Some(image) => self.push_block(DBlock::Figure {
                    image,
                    caption: Vec::new(),
                }),
                None => self.push_block(DBlock::Paragraph(inl)),
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

    pub(super) fn push_block(&mut self, block: DBlock) {
        match self.containers.last_mut() {
            Some(c) => c.blocks.push(block),
            None => {
                let anchors = std::mem::take(&mut self.ids);
                self.tops.push(Top { block, anchors });
            }
        }
    }

    // ---- inline assembly --------------------------------------------------

    pub(super) fn target(&mut self) -> &mut Vec<DInline> {
        match self.links.last_mut() {
            Some(l) => &mut l.inlines,
            None => &mut self.acc,
        }
    }

    pub(super) fn last_is_space(&self) -> bool {
        self.links
            .iter()
            .rev()
            .find_map(|l| ends_with_space(&l.inlines))
            .or_else(|| ends_with_space(&self.acc))
            .unwrap_or(true)
    }

    pub(super) fn space(&mut self) {
        if self.open != Open::None && !self.last_is_space() {
            self.push_text(" ".into());
        }
    }

    pub(super) fn style(&self) -> Style {
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

    pub(super) fn push_text(&mut self, text: String) {
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
    pub(super) fn close_links(&mut self, from: usize) {
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
