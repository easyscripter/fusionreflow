import 'dart:async';

import 'package:flow_render/src/layout/flow_page.dart';
import 'package:flow_render/src/style/flow_style.dart';
import 'package:flow_render/src/widgets/flow_image_cache.dart';
import 'package:flow_render/src/widgets/flow_page_painter.dart';
import 'package:flutter/widgets.dart';

/// Draws one page of a chapter (text without headers and footers). Its size
/// is the one the page was laid out for.
class FlowPageView extends StatefulWidget {
  const new({required this.page, required this.style, super.key});

  final FlowPage page;
  final FlowStyle style;

  /// Starts decoding the pictures of [page], so that a view of it built
  /// later draws them at once.
  static Future<void> precache(FlowPage page) => FlowImageCache.precache(page);

  @override
  State<FlowPageView> createState() => _FlowPageViewState();
}

class _FlowPageViewState extends State<FlowPageView> {
  /// Changes when a picture becomes ready, to repaint.
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(FlowPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) _decode();
  }

  void _decode() {
    final page = widget.page;
    for (final bytes in FlowImageCache.picturesOf(page)) {
      if (FlowImageCache.lookup(bytes) != null) continue;
      unawaited(
        FlowImageCache.load(bytes).then((_) {
          if (mounted && widget.page == page) setState(() => _revision++);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: FlowPagePainter(
      page: widget.page,
      style: widget.style,
      image: FlowImageCache.lookup,
      revision: _revision,
    ),
  );
}
