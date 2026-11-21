import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flow_render/src/layout/flow_page.dart';
import 'package:flow_render/src/style/flow_style.dart';
import 'package:flutter/rendering.dart';

/// Paints one [FlowPage]; [images] are the decoded pictures by their bytes
/// (compared by identity).
class FlowPagePainter extends CustomPainter {
  const new({required this.page, required this.style, required this.images});

  final FlowPage page;
  final FlowStyle style;
  final Map<Uint8List, ui.Image> images;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = style.mutedColor;
    for (final item in page.items) {
      switch (item) {
        case FlowLineItem():
          _paintLine(canvas, item);
        case FlowLabelItem():
          item.painter.paint(canvas, item.rect.topLeft);
        case FlowPictureItem():
          _paintPicture(canvas, item);
        case FlowRuleItem():
          canvas.drawRect(item.rect, line);
        case FlowRowItem():
          _paintRow(canvas, item, line);
      }
    }
  }

  void _paintLine(Canvas canvas, FlowLineItem item) {
    final shift = Offset(item.rect.left, item.rect.top - item.top);
    canvas
      ..save()
      ..clipRect(item.rect)
      ..translate(shift.dx, shift.dy);
    item.painter.paint(canvas, Offset.zero);
    for (final inline in item.inlineImages) {
      final image = images[inline.bytes];
      if (image == null) continue;
      _drawImage(canvas, image, inline.box);
    }
    canvas.restore();
  }

  void _paintPicture(Canvas canvas, FlowPictureItem item) {
    final image = images[item.bytes];
    if (item.broken || image == null) {
      if (item.broken) {
        canvas.drawRect(
          item.rect.deflate(0.5),
          Paint()
            ..color = style.mutedColor
            ..style = PaintingStyle.stroke,
        );
      }
      return;
    }
    _drawImage(canvas, image, item.rect);
  }

  void _drawImage(Canvas canvas, ui.Image image, Rect target) =>
      paintImage(canvas: canvas, rect: target, image: image);

  void _paintRow(Canvas canvas, FlowRowItem item, Paint line) {
    final rect = item.rect;
    canvas
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.top, rect.right, rect.top + 1),
        line,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.bottom - 1, rect.right, rect.bottom),
        line,
      );
    for (final x in item.columnXs) {
      canvas.drawRect(Rect.fromLTRB(x, rect.top, x + 1, rect.bottom), line);
    }
    for (final cell in item.cells) {
      cell.painter.paint(canvas, cell.rect.topLeft);
    }
  }

  @override
  bool shouldRepaint(FlowPagePainter oldDelegate) =>
      oldDelegate.page != page ||
      oldDelegate.style != style ||
      oldDelegate.images != images;
}
