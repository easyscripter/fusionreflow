import 'dart:math' as math;
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
const double _cellPadX = 6;
const double _cellPadY = 4;
const double _brokenImageLines = 3;

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
  });

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

/// Splits a chapter into pages with a [LineBreaker].
class FlowPaginator {
  const new({this.lineBreaker = const EngineLineBreaker()});

  final LineBreaker lineBreaker;

  /// Pages of [section] for a page of [size]. Never empty: an empty section
  /// gives one empty page.
  Future<List<FlowPage>> paginate(
    FlowSection section,
    ui.Size size,
    FlowStyle style,
  ) => _Run(lineBreaker, section, size, style).paginate();
}

class _Run {
  new(this.breaker, this.section, this.size, this.style)
    : width = math.max(1, size.width - style.padding.horizontal),
      height = math.max(1, size.height - style.padding.vertical);

  final LineBreaker breaker;
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

  Future<_Laid> _layout(int index) async =>
      _laid[index] ??= await _layoutBlock(index);

  Future<_Laid> _layoutBlock(int index) async {
    final block = section.blocks[index];
    final start = _starts[index];
    return switch (block) {
      FlowText() => _layoutText(block, start),
      FlowImage() => await _layoutImage(block, start),
      FlowRule() => _layoutRule(start),
      FlowTable() => _layoutTable(block, start),
    };
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
    final lines = breaker.breakLines(block, textWidth, style);
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
          : null,
      keepTogether: isHeading,
      keepWithNext: isHeading,
      lineRules: !isHeading,
    );
  }

  /// Space before and after a text block, in lines.
  (double, double) _spacing(FlowText block) => switch (block.role) {
    FlowTextRole.heading => _pair(1, 0.8),
    FlowTextRole.body when block.marker == null => _pair(0, 0),
    _ => _pair(0.5, 0.5),
  };

  static (double, double) _pair(double before, double after) => (before, after);

  // ---- image and rule ---------------------------------------------------

  Future<_Laid> _layoutImage(FlowImage block, int start) async {
    final natural = await readImageSize(block.bytes);
    final double w;
    final double h;
    if (natural == null) {
      w = width;
      h = _brokenImageLines * _line;
    } else {
      final scale = math.min(
        1,
        math.min(width / natural.width, height / natural.height),
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

  FlowText _cellText(List<FlowSpan> cell) =>
      FlowText(cell, role: FlowTextRole.footnote);

  TextPainter? _cellPainter(List<FlowSpan> cell, double width) {
    if (spansLength(cell) == 0) return null;
    final built = buildText(_cellText(cell), style);
    // Same styling as the table text size.
    final scaled = BuiltText(
      TextSpan(
        style: built.span.style?.copyWith(
          fontSize: style.fontSize * _tableTextScale,
          color: style.textColor,
        ),
        children: built.span.children,
      ),
      built.placeholders,
      built.images,
      built.prefix,
    );
    return layoutPainter(scaled, TextAlign.left, width);
  }

  _Laid _layoutTable(FlowTable table, int start) {
    if (table.rows.isEmpty) return const _Laid([]);
    final columns = table.rows.fold(0, (m, r) => math.max(m, r.length));
    final content = List<double>.filled(columns, 0);
    final minimum = List<double>.filled(columns, 0);
    for (final row in table.rows) {
      for (var c = 0; c < row.length; c++) {
        final text = row[c].whereType<FlowTextSpan>().map((s) => s.text).join();
        if (text.trim().isEmpty) continue;
        content[c] = math.max(content[c], _oneLine(text));
        for (final word in text.split(RegExp(r'\s+'))) {
          minimum[c] = math.max(minimum[c], _oneLine(word));
        }
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
                    FlowLabelItem(
                      Rect.fromLTWH(
                        xs[c] + _cellPadX,
                        top + _cellPadY,
                        painter.width,
                        painter.height,
                      ),
                      painter,
                    ),
              ],
            ),
          ],
        ),
      );
    }
    return _Laid(rows, before: 0.5 * _line, after: 0.5 * _line);
  }

  double _oneLine(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _cellStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
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
      if (!_atTop && gap + need > height - _y) {
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

  /// Room a heading needs after itself: spacing and the first row of the next
  /// block.
  Future<double> _nextNeed(int index, _Laid laid) async {
    for (var next = index + 1; next < section.blocks.length; next++) {
      final nextLaid = await _layout(next);
      if (nextLaid.rows.isEmpty) continue;
      // A paragraph is not started with one line: two rows must fit.
      final rows = nextLaid.lineRules ? math.min(2, nextLaid.rows.length) : 1;
      final first = nextLaid.rows
          .take(rows)
          .fold<double>(0, (s, r) => s + r.height);
      return math.max(laid.after, nextLaid.before) + first;
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
