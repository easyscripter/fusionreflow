import 'dart:async';

import 'package:flow_render/src/layout/flow_page.dart';
import 'package:flow_render/src/style/flow_style.dart';
import 'package:flow_render/src/widgets/flow_images.dart';
import 'package:flow_render/src/widgets/flow_page_painter.dart';
import 'package:flutter/widgets.dart';

/// Draws one page of a chapter (text without headers and footers). Its size
/// is the one the page was laid out for.
class FlowPageView extends StatefulWidget {
  const new({required this.page, required this.style, this.images, super.key});

  final FlowPage page;
  final FlowStyle style;

  /// Pictures shared with other views; their owner calls `show`. Null: the
  /// view keeps the pictures of its page itself.
  final FlowImages? images;

  @override
  State<FlowPageView> createState() => _FlowPageViewState();
}

class _FlowPageViewState extends State<FlowPageView> {
  FlowImages? _own;

  FlowImages get _images => widget.images ?? (_own ??= FlowImages());

  void _load() {
    if (widget.images != null) return;
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    unawaited(_images.show([widget.page], ratio));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(FlowPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) _load();
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: widget.page.text,
    textDirection: TextDirection.ltr,
    child: CustomPaint(
      size: Size.infinite,
      painter: FlowPagePainter(
        page: widget.page,
        style: widget.style,
        images: _images,
      ),
    ),
  );
}
