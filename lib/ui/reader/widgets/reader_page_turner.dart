import 'dart:async';

import 'package:flow_render/flow_render.dart';
import 'package:flow_render/widgets.dart';
import 'package:flutter/material.dart';

/// Share of the width at each edge where a tap turns the page.
const double _tapZone = 0.3;

/// Share of the width a drag must pass to turn the page.
const double _turnShare = 0.25;

/// Fling speed that turns the page, dp/s.
const double _flingSpeed = 700;

const Duration _turnDuration = Duration(milliseconds: 250);

/// Shows [current] and turns to [previous] / [next] by a drag (the page
/// slides under the finger) or a tap at an edge; the middle does nothing.
class ReaderPageTurner extends StatefulWidget {
  const new({
    required this.current,
    required this.style,
    required this.onTurn,
    this.previous,
    this.next,
    super.key,
  });

  final FlowPage current;
  final FlowPage? previous;
  final FlowPage? next;
  final FlowStyle style;

  /// Called with +1 or -1 when the slide has ended.
  final ValueChanged<int> onTurn;

  @override
  State<ReaderPageTurner> createState() => _ReaderPageTurnerState();
}

class _ReaderPageTurnerState extends State<ReaderPageTurner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _turnDuration,
  );

  final FlowImages _images = FlowImages();

  /// Slide of the current page in dp: negative towards the next page.
  double _offset = 0;
  double _from = 0;
  double _to = 0;
  int _turning = 0;

  /// Pictures of the shown page and its neighbours, so a turn does not wait.
  void _loadImages() {
    unawaited(
      _images.show(
        [widget.previous, widget.current, widget.next].nonNulls,
        MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadImages();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final t = Curves.easeOut.transform(_controller.value);
      setState(() => _offset = _from + (_to - _from) * t);
    });
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed || _turning == 0) return;
      // The slide stays at the edge until the new page arrives.
      widget.onTurn(_turning);
    });
  }

  @override
  void didUpdateWidget(ReaderPageTurner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current ||
        oldWidget.next != widget.next ||
        oldWidget.previous != widget.previous) {
      _loadImages();
    }
    if (oldWidget.current != widget.current) {
      _controller.stop();
      _offset = 0;
      _turning = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _images.dispose();
    super.dispose();
  }

  bool _can(int direction) =>
      (direction > 0 ? widget.next : widget.previous) != null;

  /// Slides to [target] and, for a turn, reports it.
  void _slide(double target, {int turn = 0}) {
    _controller.stop();
    _from = _offset;
    _to = target;
    _turning = turn;
    _controller.forward(from: 0);
  }

  void _turn(int direction, double width) {
    if (_turning != 0 || !_can(direction)) return;
    _slide(-direction * width, turn: direction);
  }

  void _dragUpdate(DragUpdateDetails details, double width) {
    if (_turning != 0) return;
    _controller.stop();
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(
        _can(1) ? -width : 0,
        _can(-1) ? width : 0,
      );
    });
  }

  void _dragEnd(DragEndDetails details, double width) {
    if (_turning != 0) return;
    final speed = details.primaryVelocity ?? 0;
    final direction = _offset < -width * _turnShare || speed < -_flingSpeed
        ? 1
        : _offset > width * _turnShare || speed > _flingSpeed
        ? -1
        : 0;
    if (direction != 0 && _can(direction)) {
      _slide(-direction * width, turn: direction);
    } else {
      _slide(0);
    }
  }

  void _tap(TapUpDetails details, double width) {
    final x = details.localPosition.dx;
    if (x < width * _tapZone) {
      _turn(-1, width);
    } else if (x > width * (1 - _tapZone)) {
      _turn(1, width);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      // The key sits on the child of the Stack, so a page keeps its state
      // when a neighbour appears next to it. The boundary lets the slide move
      // a ready picture of the page instead of painting it every frame.
      Widget place(FlowPage page, double dx) => Transform.translate(
        key: ObjectKey(page),
        offset: Offset(dx, 0),
        child: RepaintBoundary(
          child: FlowPageView(page: page, style: widget.style, images: _images),
        ),
      );
      return Semantics(
        // Screen readers turn pages by scrolling.
        onScrollLeft: _can(1) ? () => _turn(1, width) : null,
        onScrollRight: _can(-1) ? () => _turn(-1, width) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapUp: (details) => _tap(details, width),
          onHorizontalDragUpdate: (details) => _dragUpdate(details, width),
          onHorizontalDragEnd: (details) => _dragEnd(details, width),
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_offset > 0 && widget.previous != null)
                  place(widget.previous!, _offset - width),
                if (_offset < 0 && widget.next != null)
                  place(widget.next!, _offset + width),
                place(widget.current, _offset),
              ],
            ),
          ),
        ),
      );
    },
  );
}
