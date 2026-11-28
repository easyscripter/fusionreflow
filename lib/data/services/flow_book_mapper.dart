import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flow_render/flow_render.dart';
import 'package:fusionreflow/src/rust/api/book.dart' as rb;

/// Blocks per chapter of a book without a table of contents and headings.
const int _chunkBlocks = 200;

/// Deepest heading that starts a chapter when there is no table of contents.
const int _chapterHeadingLevel = 2;

const _softHyphen = '­';

/// Converts the bridge book into the render model: chapters of blocks.
FlowBook flowBookOf(rb.Book book) {
  final resources = {for (final r in book.resources) r.id.field0: r.data};
  final (:starts, :chunks) = _chapterStarts(book);
  final titles = _chapterTitles(book, starts);
  final mapper = _BlockMapper(resources);
  final sections = <FlowSection>[];
  for (var i = 0; i < starts.length; i++) {
    final end = i + 1 < starts.length ? starts[i + 1] : book.blocks.length;
    sections.add(
      FlowSection(
        mapper.blocks(book.blocks.sublist(starts[i], end)),
        title: titles[starts[i]],
        chunk: chunks,
      ),
    );
  }
  return FlowBook(book.meta.title, sections);
}

/// Sorted block indices where chapters start; always begins with 0. `chunks`
/// says they are pieces cut by size.
({List<int> starts, bool chunks}) _chapterStarts(rb.Book book) {
  final count = book.blocks.length;
  final fromToc = {
    for (final entry in book.toc)
      if (entry.block >= BigInt.zero && entry.block < BigInt.from(count))
        entry.block.toInt(),
  };
  final starts = fromToc.isNotEmpty
      ? fromToc
      : {
          for (var i = 0; i < count; i++)
            if (_headingLevel(book.blocks[i]) <= _chapterHeadingLevel) i,
        };
  if (starts.isEmpty) {
    return (
      starts: [for (var i = 0; i < math.max(count, 1); i += _chunkBlocks) i],
      chunks: true,
    );
  }
  return (starts: ({0, ...starts}.toList())..sort(), chunks: false);
}

/// Heading level of [node], or a huge number for other blocks.
int _headingLevel(rb.BlockNode node) => switch (node.block) {
  rb.Block_Heading(:final level) => level,
  _ => 1 << 30,
};

/// Chapter titles by the chapter's first block.
Map<int, String?> _chapterTitles(rb.Book book, List<int> starts) {
  final titles = <int, String?>{for (final s in starts) s: null};
  if (book.toc.any((e) => titles.containsKey(e.block.toInt()))) {
    for (final entry in book.toc) {
      final block = entry.block.toInt();
      if (titles.containsKey(block)) titles[block] = entry.title;
    }
    return titles;
  }
  for (final start in starts) {
    if (start < book.blocks.length &&
        _headingLevel(book.blocks[start]) <= _chapterHeadingLevel) {
      final block = book.blocks[start].block as rb.Block_Heading;
      titles[start] = _plain(block.inlines).replaceAll(_softHyphen, '');
    }
  }
  return titles;
}

String _plain(List<rb.Inline> inlines) => inlines
    .map(
      (i) => switch (i) {
        rb.Inline_Text(:final text) => text,
        rb.Inline_Link(:final inlines) => _plain(inlines),
        rb.Inline_NoteRef(:final label) => label,
        rb.Inline_Image() => '',
      },
    )
    .join();

class _BlockMapper {
  const new(this._resources);

  final Map<int, Uint8List> _resources;

  Uint8List _bytes(rb.ResourceId id) => _resources[id.field0] ?? Uint8List(0);

  List<FlowBlock> blocks(
    List<rb.BlockNode> nodes, {
    int indent = 0,
    bool footnote = false,
  }) => [for (final node in nodes) ..._block(node.block, indent, footnote)];

  Iterable<FlowBlock> _block(rb.Block block, int indent, bool footnote) {
    final role = footnote ? FlowTextRole.footnote : FlowTextRole.body;
    return switch (block) {
      rb.Block_Paragraph(:final inlines) => [
        FlowText(_spans(inlines), role: role, indent: indent),
      ],
      rb.Block_Heading(:final level, :final inlines) => [
        FlowText(
          _spans(inlines),
          role: footnote ? FlowTextRole.footnote : FlowTextRole.heading,
          headingLevel: level,
          indent: indent,
        ),
      ],
      rb.Block_ListItem(:final marker, :final depth, :final inlines) => [
        FlowText(
          _spans(inlines),
          role: role,
          marker: switch (marker) {
            rb.ListMarker_Bullet() => '•',
            rb.ListMarker_Number(:final field0) => '$field0.',
          },
          indent: indent + depth,
        ),
      ],
      rb.Block_Quote(:final blocks) => this.blocks(
        blocks,
        indent: indent + 1,
        footnote: footnote,
      ),
      rb.Block_Code(:final lines) => [
        for (final line in lines)
          FlowText([FlowTextSpan(line)], role: FlowTextRole.code),
      ],
      rb.Block_Footnote(:final blocks) => this.blocks(
        blocks,
        indent: indent,
        footnote: true,
      ),
      rb.Block_Figure(:final image, :final caption) => [
        FlowImage(_bytes(image)),
        if (caption.isNotEmpty)
          FlowText(_spans(caption), role: FlowTextRole.caption),
      ],
      rb.Block_Formula(:final image) ||
      rb.Block_FixedPage(:final image) => [FlowImage(_bytes(image))],
      rb.Block_Table(:final field0) => [
        FlowTable([
          for (final row in field0.rows) [for (final cell in row) _spans(cell)],
        ]),
      ],
      rb.Block_Separator() => const [FlowRule()],
    };
  }

  List<FlowSpan> _spans(List<rb.Inline> inlines, {bool link = false}) => [
    for (final inline in inlines)
      ...switch (inline) {
        rb.Inline_Text(:final text, :final style) => [
          FlowTextSpan(
            text,
            bold: style.bold,
            italic: style.italic,
            code: style.code,
            link: link,
            script: switch (style.script) {
              rb.Script.normal => FlowScript.normal,
              rb.Script.sup => FlowScript.sup,
              rb.Script.sub => FlowScript.sub,
            },
          ),
        ],
        rb.Inline_Link(:final inlines) => _spans(inlines, link: true),
        rb.Inline_NoteRef(:final label) => [
          FlowTextSpan(label, link: true, script: FlowScript.sup),
        ],
        rb.Inline_Image(:final res, :final heightEm) => [
          FlowImageSpan(_bytes(res), heightEm),
        ],
      },
  ];
}
