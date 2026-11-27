import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flow_render/src/layout/flow_page.dart';
import 'package:flow_render/src/layout/text_build.dart';
import 'package:flow_render/src/model/flow_block.dart';
import 'package:flow_render/src/style/flow_style.dart';
import 'package:flutter/painting.dart';

/// A line of a paragraph: text range `[start, end)` of the block, its [height],
/// and what is needed to draw it.
class FlowLine {
  const new({
    required this.start,
    required this.end,
    required this.height,
    required this.top,
    required this.painter,
    required this.inlineImages,
  });

  final int start;
  final int end;
  final double height;

  /// Distance from the top of [painter] to this line.
  final double top;
  final TextPainter painter;
  final List<FlowInlineImage> inlineImages;
}

/// Splits a text block into lines. 5.B adds its own implementation.
abstract interface class LineBreaker {
  /// [imageRatios]: width / height of the inline pictures by their bytes.
  List<FlowLine> breakLines(
    FlowText block,
    double width,
    FlowStyle style, {
    Map<Uint8List, double> imageRatios,
  });
}

/// Lines as the Flutter engine breaks them (`TextPainter`).
class EngineLineBreaker implements LineBreaker {
  const new();

  @override
  List<FlowLine> breakLines(
    FlowText block,
    double width,
    FlowStyle style, {
    Map<Uint8List, double> imageRatios = const {},
  }) {
    final length = block.length;
    if (length == 0) return const [];
    final built = buildText(
      block,
      style,
      maxWidth: width,
      imageRatios: imageRatios,
    );
    final painter = layoutPainter(built, roleAlign(block, style), width);
    final metrics = painter.computeLineMetrics();
    final boxes = painter.inlinePlaceholderBoxes ?? const [];
    final lines = <FlowLine>[];
    var top = 0.0;
    var previousStart = 0;
    for (var i = 0; i < metrics.length; i++) {
      final height = metrics[i].height;
      final probe = painter.getPositionForOffset(Offset(0, top + height / 2));
      final start = i == 0
          ? 0
          : math.min(
              length,
              math.max(previousStart, probe.offset - built.prefix),
            );
      lines.add(
        FlowLine(
          start: start,
          end: length,
          height: height,
          top: top,
          painter: painter,
          inlineImages: [
            for (var b = 0; b < boxes.length && b < built.images.length; b++)
              if (built.images[b] case final bytes?
                  when boxes[b].top >= top - 0.5 &&
                      boxes[b].top < top + height - 0.5)
                FlowInlineImage(boxes[b].toRect(), bytes),
          ],
        ),
      );
      previousStart = start;
      top += height;
    }
    // A line ends where the next one starts.
    return [
      for (var i = 0; i < lines.length; i++)
        FlowLine(
          start: lines[i].start,
          end: i + 1 < lines.length ? lines[i + 1].start : length,
          height: lines[i].height,
          top: lines[i].top,
          painter: painter,
          inlineImages: lines[i].inlineImages,
        ),
    ];
  }
}
