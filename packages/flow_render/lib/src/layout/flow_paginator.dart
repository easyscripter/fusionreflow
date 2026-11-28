import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flow_render/src/layout/flow_page.dart';
import 'package:flow_render/src/layout/image_size.dart';
import 'package:flow_render/src/layout/line_breaker.dart';
import 'package:flow_render/src/layout/table_columns.dart';
import 'package:flow_render/src/layout/text_build.dart';
import 'package:flow_render/src/model/flow_block.dart';
import 'package:flow_render/src/model/flow_book.dart';
import 'package:flow_render/src/model/flow_span.dart';
import 'package:flow_render/src/style/flow_style.dart';
import 'package:flutter/painting.dart';

const double _levelEm = 1.5;
const int _maxLevels = 4;
const double _tableTextScale = 0.9;
const double _cellPadX = 8;
const double _cellPadY = 4;
const double _brokenImageLines = 3;
const double _captionGap = 8;

/// Longest stretch of layout work without giving the event loop a turn.
const int _sliceMs = 8;

/// A piece of a block that never splits across pages: a text line, an image,
/// a table row.
class _Row {
  const new(this.height, this.start, this.end, this.build);

  final double height;
  final int start;
  final int end;

  /// Items of the row for `top`, the page y of its top edge.
  final List<FlowPageItem> Function(double top) build;
}

class _Laid {
  const new(
    this.rows, {
    this.before = 0,
    this.after = 0,
    this.group,
    this.keepTogether = false,
    this.keepWithNext = false,
    this.lineRules = false,
    this.picture = false,
    this.caption = false,
  });

  /// A caption sits close under its picture.
  final bool picture;
  final bool caption;

  final List<_Row> rows;

  /// Spacing in px.
  final double before;
  final double after;

  /// Neighbours of the same group sit without a gap (code lines, list items).
  final String? group;

  /// Never split if it fits a page.
  final bool keepTogether;
  final bool keepWithNext;

  /// Widow and orphan control applies (paragraphs).
  final bool lineRules;
}

/// Gives the event loop a turn (timers, input, frames).
Future<void> yieldToEventLoop() => Future<void>.delayed(Duration.zero);

/// Splits a chapter into pages with a [LineBreaker].
class FlowPaginator {
  const new({
    this.lineBreaker = const EngineLineBreaker(),
    this.pause = yieldToEventLoop,
  });

  final LineBreaker lineBreaker;

  /// Called between the pieces of a long layout so the UI can draw. Tests
  /// with a fake clock pass one that completes at once.
  final Future<void> Function() pause;

  /// Pages of [section] for a page of [size]. Never empty: an empty section
  /// gives one empty page.
  Future<List<FlowPage>> paginate(
    FlowSection section,
    ui.Size size,
    FlowStyle style,
  ) => _Run(lineBreaker, pause, section, size, style).paginate();
}

class _Run {
  new(this.breaker, this.pause, this.section, this.size, this.style)
    : width = math.max(1, size.width - style.padding.horizontal),
      height = math.max(1, size.height - style.padding.vertical);

  final LineBreaker breaker;
  final Future<void> Function() pause;
  final FlowSection section;
  final ui.Size size;
  final FlowStyle style;
  final double width;
  final double height;

  final _laid = <int, _Laid>{};
  final _starts = <int>[];
  final _pages = <({int start, List<FlowPageItem> items})>[];
  var _items = <FlowPageItem>[];
  int? _pageStart;
  var _y = 0.0;

  double get _line => style.line;

  final _slice = Stopwatch()..start();

  /// Lets the UI draw frames during a long layout.
  Future<void> _breathe() async {
    if (_slice.elapsedMilliseconds < _sliceMs) return;
    await pause();
    _slice.reset();
  }

  Future<_Laid> _layout(int index) async =>
      _laid[index] ??= await _layoutBlock(index);

  Future<_Laid> _layoutBlock(int index) async {
    final block = section.blocks[index];
    final start = _starts[index];
    switch (block) {
      case FlowText():
        await _readRatios(block.spans);
        return _layoutText(block, start);
      case FlowImage():
        final reserved = await _headingsAbove(index);
        return await _layoutImage(block, start, height - reserved);
      case FlowRule():
        return _layoutRule(start);
      case FlowTable():
        for (final row in block.rows) {
          for (final cell in row) {
            await _readRatios(cell);
          }
        }
        return await _layoutTable(block, start);
    }
  }

  /// Height the headings right before block [index] take with their spacing:
  /// a picture has to leave them room on its page.
  Future<double> _headingsAbove(int index) async {
    var taken = 0.0;
    var spaceBelow = 0.5 * _line; // the picture's own space above
    for (var i = index - 1; i >= 0; i--) {
      final block = section.blocks[i];
      if (block is! FlowText || block.role != FlowTextRole.heading) break;
      final laid = await _layout(i);
      if (laid.rows.isEmpty) continue;
      taken +=
          laid.rows.fold<double>(0, (sum, r) => sum + r.height) +
          math.max(laid.after, spaceBelow);
      spaceBelow = laid.before;
    }
    // Headings that fill half a page keep it to themselves.
    return taken < height / 2 ? taken : 0;
  }

  /// Width / height of the inline pictures, by their bytes.
  final _ratios = Map<Uint8List, double>.identity();

  /// Reads the size of the inline pictures of [spans] once.
  Future<void> _readRatios(List<FlowSpan> spans) async {
    for (final span in spans.whereType<FlowImageSpan>()) {
      if (_ratios.containsKey(span.bytes)) continue;
      final size = await readImageSize(span.bytes);
      if (size != null) _ratios[span.bytes] = size.width / size.height;
    }
  }

  // ---- text -------------------------------------------------------------

  _Laid _layoutText(FlowText block, int start) {
    final em = style.fontSize;
    final levels = math.min(block.indent, _maxLevels);
    final marker = block.marker;
    final left = style.padding.left + levels * _levelEm * em;
    final textX = marker == null ? left : left + _levelEm * em;
    final textWidth = math.max<double>(
      1,
      size.width - style.padding.right - textX,
    );
    final lines = breaker.breakLines(
      block,
      textWidth,
      style,
      imageRatios: _ratios,
    );
    if (lines.isEmpty) return const _Laid([]);

    TextPainter? markerPainter;
    if (marker != null) {
      markerPainter = layoutLabel(
        marker,
        TextStyle(
          fontFamily: style.fontFamily,
          fontSize: style.fontSize,
          height: style.lineHeight,
          color: style.textColor,
        ),
      );
    }
    final isHeading = block.role == FlowTextRole.heading;
    final plain = plainText(block.spans);
    final rows = <_Row>[
      for (var i = 0; i < lines.length; i++)
        _Row(
          lines[i].height,
          start + lines[i].start,
          start + lines[i].end,
          (top) => [
            FlowLineItem(
              Rect.fromLTWH(textX, top, textWidth, lines[i].height),
              painter: lines[i].painter,
              top: lines[i].top,
              start: start + lines[i].start,
              end: start + lines[i].end,
              paragraphStart: start,
              paragraphLines: lines.length,
              isHeading: isHeading,
              inlineImages: lines[i].inlineImages,
              text: spoken(plain.substring(lines[i].start, lines[i].end)),
            ),
            if (i == 0 && markerPainter != null)
              FlowLabelItem(
                Rect.fromLTWH(
                  textX - 0.3 * em - markerPainter.width,
                  top,
                  markerPainter.width,
                  lines[i].height,
                ),
                markerPainter,
              ),
          ],
        ),
    ];
    final spacing = _spacing(block);
    return _Laid(
      rows,
      before: spacing.$1 * _line,
      after: spacing.$2 * _line,
      group: marker != null
          ? 'list'
          : block.role == FlowTextRole.code
          ? 'code'
          : block.indent > 0
          ? 'quote'
          : null,
      caption: block.role == FlowTextRole.caption,
      keepTogether: isHeading,
      keepWithNext: isHeading,
      lineRules: !isHeading,
    );
  }

  /// Space before and after a text block, in lines.
  (double, double) _spacing(FlowText block) => switch (block.role) {
    FlowTextRole.heading => _pair(1, 0.8),
    FlowTextRole.body when block.marker == null && block.indent == 0 => _pair(
      0,
      0,
    ),
    _ => _pair(0.5, 0.5),
  };

  static (double, double) _pair(double before, double after) => (before, after);

  // ---- image and rule ---------------------------------------------------

  Future<_Laid> _layoutImage(
    FlowImage block,
    int start,
    double maxHeight,
  ) async {
    final natural = await readImageSize(block.bytes);
    final double w;
    final double h;
    if (natural == null) {
      w = width;
      h = _brokenImageLines * _line;
    } else {
      final scale = math.min(
        1,
        math.min(width / natural.width, maxHeight / natural.height),
      );
      w = natural.width * scale;
      h = natural.height * scale;
    }
    final x = style.padding.left + (width - w) / 2;
    return _Laid(
      [
        _Row(
          h,
          start,
          start + 1,
          (top) => [
            FlowPictureItem(
              Rect.fromLTWH(x, top, w, h),
              bytes: block.bytes,
              broken: natural == null,
            ),
          ],
        ),
      ],
      before: 0.5 * _line,
      after: 0.5 * _line,
      keepTogether: true,
      picture: true,
    );
  }

  _Laid _layoutRule(int start) {
    final w = width / 3;
    return _Laid(
      [
        _Row(
          1,
          start,
          start + 1,
          (top) => [
            FlowRuleItem(
              Rect.fromLTWH(style.padding.left + (width - w) / 2, top, w, 1),
            ),
          ],
        ),
      ],
      before: _line,
      after: _line,
      keepTogether: true,
    );
  }

  // ---- table ------------------------------------------------------------

  TextStyle get _cellStyle => TextStyle(
    fontFamily: style.fontFamily,
    fontSize: style.fontSize * _tableTextScale,
    height: style.lineHeight,
    color: style.textColor,
  );

  /// A cell ready for a `TextPainter`: the table text size and color.
  BuiltText _cell(List<FlowSpan> cell, double maxWidth) {
    final built = buildText(
      FlowText(cell, role: FlowTextRole.footnote),
      style,
      maxWidth: maxWidth,
      fontSize: style.fontSize * _tableTextScale,
      imageRatios: _ratios,
    );
    return BuiltText(
      TextSpan(
        style: built.span.style?.merge(_cellStyle),
        children: built.span.children,
      ),
      built.placeholders,
      built.images,
      built.prefix,
    );
  }

  TextPainter? _cellPainter(List<FlowSpan> cell, double width) {
    if (spansLength(cell) == 0) return null;
    return layoutPainter(_cell(cell, width), TextAlign.left, width);
  }

  /// Widest one-line content and longest word of [cell], as drawn (bold,
  /// italic, pictures).
  (double, double) _measure(List<FlowSpan> cell) {
    if (spansLength(cell) == 0) return (0.0, 0.0);
    final built = _cell(cell, width);
    final painter =
        TextPainter(text: built.span, textDirection: TextDirection.ltr)
          ..setPlaceholderDimensions(built.placeholders)
          ..layout();
    return (
      painter.maxIntrinsicWidth.ceilToDouble(),
      painter.minIntrinsicWidth.ceilToDouble(),
    );
  }

  Future<_Laid> _layoutTable(FlowTable table, int start) async {
    if (table.rows.isEmpty) return const _Laid([]);
    final columns = table.rows.fold(0, (m, r) => math.max(m, r.length));
    final content = List<double>.filled(columns, 0);
    final minimum = List<double>.filled(columns, 0);
    for (final row in table.rows) {
      await _breathe();
      for (var c = 0; c < row.length; c++) {
        final (widest, word) = _measure(row[c]);
        content[c] = math.max(content[c], widest);
        minimum[c] = math.max(minimum[c], word);
      }
    }
    final inner = [for (var c = 0; c < columns; c++) _cellPadX * 2];
    final widths = tableColumnWidths(
      content: [for (var c = 0; c < columns; c++) content[c] + inner[c]],
      minimum: [for (var c = 0; c < columns; c++) minimum[c] + inner[c]],
      available: width - 1,
    );
    final xs = <double>[style.padding.left];
    for (final w in widths) {
      xs.add(xs.last + w);
    }

    final rows = <_Row>[];
    var offset = start;
    for (var r = 0; r < table.rows.length; r++) {
      await _breathe();
      final rowStart = offset;
      offset += table.rowLength(r);
      final cells = table.rows[r];
      final painters = [
        for (var c = 0; c < cells.length; c++)
          _cellPainter(
            cells[c],
            math.max<double>(1, widths[c] - 2 * _cellPadX),
          ),
      ];
      final rowHeight =
          math.max(
            _line,
            painters.fold<double>(0, (m, p) => math.max(m, p?.height ?? 0)),
          ) +
          2 * _cellPadY;
      if (rowHeight > height) {
        rows.addAll(_stackedCells(cells, rowStart));
        continue;
      }
      rows.add(
        _Row(
          rowHeight,
          rowStart,
          offset,
          (top) => [
            FlowRowItem(
              Rect.fromLTRB(xs.first, top, xs.last, top + rowHeight),
              columnXs: xs.sublist(0, painters.length + 1),
              cells: [
                for (var c = 0; c < painters.length; c++)
                  if (painters[c] case final painter?)
                    _cellItem(cells[c], painter, xs[c], top),
              ],
            ),
          ],
        ),
      );
    }
    // Like paragraphs: the header row never stays alone at the page bottom.
    return _Laid(
      rows,
      before: 0.5 * _line,
      after: 0.5 * _line,
      lineRules: true,
    );
  }

  FlowLabelItem _cellItem(
    List<FlowSpan> cell,
    TextPainter painter,
    double x,
    double top,
  ) {
    final boxes = painter.inlinePlaceholderBoxes ?? const [];
    final pictures = cell.whereType<FlowImageSpan>().toList();
    return FlowLabelItem(
      Rect.fromLTWH(
        x + _cellPadX,
        top + _cellPadY,
        painter.width,
        painter.height,
      ),
      painter,
      inlineImages: [
        for (var i = 0; i < boxes.length && i < pictures.length; i++)
          FlowInlineImage(boxes[i].toRect(), pictures[i].bytes),
      ],
      text: spoken(plainText(cell)),
    );
  }

  /// A row taller than a page: its cells one under another, as paragraphs.
  List<_Row> _stackedCells(List<List<FlowSpan>> cells, int rowStart) {
    final rows = <_Row>[];
    var offset = rowStart;
    for (final cell in cells) {
      final text = FlowText(cell);
      final laid = _layoutText(
        FlowText(cell, role: FlowTextRole.footnote),
        offset,
      );
      rows.addAll(laid.rows);
      offset += text.length + 1;
    }
    return rows;
  }

  // ---- flow -------------------------------------------------------------

  void _place(_Row row, double gap) {
    _pageStart ??= row.start;
    _y += gap;
    _items.addAll(row.build(style.padding.top + _y));
    _y += row.height;
  }

  void _newPage() {
    _pages.add((start: _pageStart ?? 0, items: _items));
    _items = [];
    _pageStart = null;
    _y = 0;
  }

  bool get _atTop => _pageStart == null;

  double _gap(_Laid? previous, _Laid next) {
    if (previous == null || _atTop) return 0;
    if (previous.group != null && previous.group == next.group) return 0;
    if (previous.picture && next.caption) return _captionGap;
    return math.max(previous.after, next.before);
  }

  Future<List<FlowPage>> paginate() async {
    var offset = 0;
    for (final block in section.blocks) {
      _starts.add(offset);
      offset += block.length;
    }
    _Laid? previous;
    for (var i = 0; i < section.blocks.length; i++) {
      await _breathe();
      final laid = await _layout(i);
      if (laid.rows.isEmpty) continue;
      await _flow(i, laid, previous);
      previous = laid;
    }
    return _finish(offset);
  }

  Future<void> _flow(int index, _Laid laid, _Laid? previous) async {
    final rows = laid.rows;
    final total = rows.fold<double>(0, (sum, r) => sum + r.height);
    var gap = _gap(previous, laid);
    if (laid.keepTogether && total <= height) {
      var need = total;
      if (laid.keepWithNext) need += await _nextNeed(index, laid);
      if (!_atTop && gap + need > height - _y + 0.01) {
        _newPage();
        gap = 0;
      }
      for (var k = 0; k < rows.length; k++) {
        _place(rows[k], k == 0 ? gap : 0);
      }
      return;
    }
    var k = 0;
    while (k < rows.length) {
      final room = height - _y - (k == 0 ? gap : 0);
      var fit = 0;
      var used = 0.0;
      while (k + fit < rows.length &&
          used + rows[k + fit].height <= room + 0.01) {
        used += rows[k + fit].height;
        fit++;
      }
      final left = rows.length - k;
      var take = left;
      if (fit < left) {
        take = fit;
        if (laid.lineRules) {
          if (left - take == 1) take--; // no widow
          if (k == 0 && take == 1) take = 0; // no orphan
        }
        if (take <= 0) {
          if (!_atTop) {
            _newPage();
            gap = 0;
            continue;
          }
          take = math.max(fit, 1); // the rule cannot be kept on this page
        }
      }
      for (var j = 0; j < take; j++) {
        _place(rows[k + j], k + j == 0 ? gap : 0);
      }
      k += take;
      if (k < rows.length) _newPage();
    }
  }

  /// Room a heading needs after itself: spacing and what of the next block
  /// has to stay with it.
  Future<double> _nextNeed(int index, _Laid laid) async {
    for (var next = index + 1; next < section.blocks.length; next++) {
      final nextLaid = await _layout(next);
      if (nextLaid.rows.isEmpty) continue;
      final gap = math.max(laid.after, nextLaid.before);
      final rows = nextLaid.rows.length;
      // Another heading moves with what follows it. A paragraph of up to
      // three lines cannot be split (widows, orphans), a longer one starts
      // with two lines.
      final count = nextLaid.keepWithNext
          ? rows
          : !nextLaid.lineRules
          ? 1
          : rows <= 3
          ? rows
          : 2;
      final first = nextLaid.rows
          .take(count)
          .fold<double>(0, (sum, r) => sum + r.height);
      final more = nextLaid.keepWithNext
          ? await _nextNeed(next, nextLaid)
          : 0.0;
      return gap + first + more;
    }
    return 0;
  }

  List<FlowPage> _finish(int length) {
    if (_pageStart != null || _pages.isEmpty) _newPage();
    return [
      for (var i = 0; i < _pages.length; i++)
        FlowPage(
          start: i == 0 ? 0 : _pages[i].start,
          end: i + 1 < _pages.length ? _pages[i + 1].start : length,
          items: _pages[i].items,
          last: i == _pages.length - 1,
        ),
    ];
  }
}
