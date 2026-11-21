import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flow_render/src/layout/flow_page.dart';
import 'package:flow_render/src/style/flow_style.dart';
import 'package:flow_render/src/widgets/flow_page_painter.dart';
import 'package:flutter/widgets.dart';

/// Draws one page of a chapter (text without headers and footers). Its size
/// is the one the page was laid out for.
class FlowPageView extends StatefulWidget {
  const new({required this.page, required this.style, super.key});

  final FlowPage page;
  final FlowStyle style;

  @override
  State<FlowPageView> createState() => _FlowPageViewState();
}

class _FlowPageViewState extends State<FlowPageView> {
  Map<Uint8List, ui.Image> _images = Map.identity();

  @override
  void initState() {
    super.initState();
    unawaited(_decode(widget.page));
  }

  @override
  void didUpdateWidget(FlowPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) unawaited(_decode(widget.page));
  }

  @override
  void dispose() {
    _release(_images);
    super.dispose();
  }

  void _release(Map<Uint8List, ui.Image> images) {
    for (final image in images.values) {
      image.dispose();
    }
  }

  Iterable<Uint8List> _pictures(FlowPage page) sync* {
    for (final item in page.items) {
      switch (item) {
        case FlowPictureItem(:final bytes, :final broken) when !broken:
          yield bytes;
        case FlowLineItem(:final inlineImages):
          for (final inline in inlineImages) {
            yield inline.bytes;
          }
        default:
      }
    }
  }

  Future<void> _decode(FlowPage page) async {
    final decoded = Map<Uint8List, ui.Image>.identity();
    for (final bytes in _pictures(page)) {
      try {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        codec.dispose();
        decoded[bytes] = frame.image;
      } on Exception {
        // A picture that cannot be decoded stays empty.
      }
    }
    if (!mounted || widget.page != page) {
      _release(decoded);
      return;
    }
    final old = _images;
    setState(() => _images = decoded);
    _release(old);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: FlowPagePainter(
      page: widget.page,
      style: widget.style,
      images: _images,
    ),
  );
}
