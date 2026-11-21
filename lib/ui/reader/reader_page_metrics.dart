import 'dart:math' as math;

import 'package:flow_render/flow_render.dart';
import 'package:flutter/painting.dart';
import 'package:fusionreflow/ui/core/theme/reader_palette.dart';
import 'package:fusionreflow/utils/window_size_class.dart';

/// Height of the header (chapter title) above the page text.
const double readerHeaderHeight = 64;

/// Space above the header text.
const double readerHeaderTop = 30;

/// Height of the footer (chapter, page, percent) under the page text.
const double readerFooterHeight = 66;

/// Side margin of the header and the footer.
const double readerChromeMargin = 24;

/// Below this window width the page is set for a small phone, dp.
const double smallPhoneMaxWidth = 380;

/// Widest column of text on a wide window, dp.
const double _maxColumn = 560;

const double _minMargin = 24;

/// Page style of task 5.A: fixed sizes by the window width (settings come
/// with 6.1).
class ReaderPageMetrics {
  const new({required this.fontSize, required this.line, required this.margin});

  /// Metrics of a window [width] dp wide (the window, not the screen: split
  /// screen and a turned phone change it).
  // ignore: unnecessary_type_name_in_constructor
  factory ReaderPageMetrics.of(double width) {
    if (width < smallPhoneMaxWidth) {
      return const ReaderPageMetrics(fontSize: 17, line: 26, margin: 20);
    }
    return switch (windowSizeClassOf(width)) {
      WindowSizeClass.compact => const ReaderPageMetrics(
        fontSize: 18,
        line: 28,
        margin: 24,
      ),
      WindowSizeClass.medium || WindowSizeClass.expanded => ReaderPageMetrics(
        fontSize: 21,
        line: 32,
        margin: math.max(_minMargin, (width - _maxColumn) / 2),
      ),
    };
  }

  final double fontSize;

  /// Line height, dp.
  final double line;

  /// Left and right margin of the text, dp.
  final double margin;

  /// The render style with the colors of [palette].
  FlowStyle style(ReaderPalette palette) => FlowStyle(
    fontFamily: 'Literata',
    codeFontFamily: 'JetBrainsMono',
    fontSize: fontSize,
    lineHeight: line / fontSize,
    padding: EdgeInsets.symmetric(horizontal: margin),
    justify: true,
    textColor: palette.pageText,
    mutedColor: palette.onSurfaceVariant,
    accentColor: palette.accent,
  );
}
