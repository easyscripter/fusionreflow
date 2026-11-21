import 'dart:typed_data';

import 'package:flutter/painting.dart';

/// An image placed inside a text line; [box] is in the painter's coordinates.
class FlowInlineImage {
  const new(this.box, this.bytes);

  final Rect box;
  final Uint8List bytes;
}

/// Something drawn on a page; [rect] is in page coordinates.
sealed class FlowPageItem {
  const new(this.rect);

  final Rect rect;
}

/// One line of a laid out paragraph: the lines of [painter] from [top] down
/// to [top] + [rect] height are drawn, clipped to [rect].
class FlowLineItem extends FlowPageItem {
  const new(
    super.rect, {
    required this.painter,
    required this.top,
    required this.start,
    required this.end,
    required this.paragraphStart,
    required this.paragraphLines,
    required this.isHeading,
    required this.inlineImages,
  });

  final TextPainter painter;
  final double top;

  /// Chapter offsets of the line: `[start, end)`.
  final int start;
  final int end;

  /// Chapter offset where the paragraph of this line starts.
  final int paragraphStart;

  /// Number of lines of the whole paragraph.
  final int paragraphLines;
  final bool isHeading;
  final List<FlowInlineImage> inlineImages;
}

/// A small text (list marker, table cell) drawn whole at the corner of [rect].
class FlowLabelItem extends FlowPageItem {
  const new(super.rect, this.painter);

  final TextPainter painter;
}

/// A picture fitted into [rect], or a frame when [broken].
class FlowPictureItem extends FlowPageItem {
  const new(super.rect, {required this.bytes, required this.broken});

  final Uint8List bytes;
  final bool broken;
}

/// A horizontal divider line.
class FlowRuleItem extends FlowPageItem {
  const new(super.rect);
}

/// A table row: cell borders and [cells].
class FlowRowItem extends FlowPageItem {
  const new(super.rect, {required this.columnXs, required this.cells});

  /// Page x of every vertical border, left to right.
  final List<double> columnXs;
  final List<FlowLabelItem> cells;
}

/// One page of a chapter: what to draw and which text it covers.
class FlowPage {
  const new({
    required this.start,
    required this.end,
    required this.items,
    this.last = false,
  });

  /// Chapter offsets: the page shows `[start, end)`.
  final int start;
  final int end;
  final List<FlowPageItem> items;

  /// The last page of the chapter also contains offset [end].
  final bool last;

  bool contains(int offset) =>
      start <= offset && (offset < end || (last && offset == end));
}

/// Index of the page of [pages] that shows [offset]; an offset outside the
/// chapter is clamped to the first or the last page.
int pageIndexOf(List<FlowPage> pages, int offset) {
  for (var i = pages.length - 1; i > 0; i--) {
    if (pages[i].start <= offset) return i;
  }
  return 0;
}
