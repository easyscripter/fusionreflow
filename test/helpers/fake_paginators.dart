import 'dart:async';
import 'dart:ui';

import 'package:flow_render/flow_render.dart';

/// Paginator whose answers a test releases by page size, in any order. The
/// answer is one empty page that ends at the width of the page.
class GatedPaginator implements FlowPaginator {
  final Map<Size, Completer<void>> _gates = {};

  Completer<void> _gate(Size size) => _gates.putIfAbsent(size, Completer.new);

  /// Lets every layout of [size] finish.
  Future<void> release(Size size) async {
    _gate(size).complete();
    await Future<void>.delayed(Duration.zero);
  }

  @override
  LineBreaker get lineBreaker => const EngineLineBreaker();

  @override
  Future<void> Function() get pause => yieldToEventLoop;

  @override
  Future<List<FlowPage>> paginate(
    FlowSection section,
    Size size,
    FlowStyle style,
  ) async {
    await _gate(size).future;
    return [
      FlowPage(start: 0, end: size.width.toInt(), items: const [], last: true),
    ];
  }
}

/// Paginator that always fails.
class FailingPaginator implements FlowPaginator {
  @override
  LineBreaker get lineBreaker => const EngineLineBreaker();

  @override
  Future<void> Function() get pause => yieldToEventLoop;

  @override
  Future<List<FlowPage>> paginate(
    FlowSection section,
    Size size,
    FlowStyle style,
  ) async => throw StateError('layout failed');
}

/// Fails only for [broken]; other chapters are laid out for real.
class FailingSectionPaginator implements FlowPaginator {
  new(this.broken);

  final FlowSection broken;

  @override
  LineBreaker get lineBreaker => const EngineLineBreaker();

  @override
  Future<void> Function() get pause => yieldToEventLoop;

  @override
  Future<List<FlowPage>> paginate(
    FlowSection section,
    Size size,
    FlowStyle style,
  ) async {
    if (section == broken) throw StateError('layout failed');
    return await const FlowPaginator().paginate(section, size, style);
  }
}

/// A real paginator that never waits for a timer: in widget tests the clock
/// is fake, and a pause on a slow machine would hang the layout.
const FlowPaginator testPaginator = FlowPaginator(pause: _noPause);

Future<void> _noPause() async {}
