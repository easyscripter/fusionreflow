import 'dart:ui' as ui;

import 'package:flow_render/flow_render.dart';
import 'package:flow_render/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_page_turner.dart';

import '../../../helpers/reader_fixtures.dart';

Future<Uint8List> _png() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawPaint(ui.Paint()..color = const Color(0xFF000000));
  final image = await recorder.endRecording().toImage(8, 8);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  testWidgets('the picture of the next page is ready before the turn', (
    tester,
  ) async {
    final bytes = (await tester.runAsync(_png))!;
    const first = FlowPage(start: 0, end: 1, items: []);
    final second = FlowPage(
      start: 1,
      end: 2,
      items: [
        FlowPictureItem(
          const Rect.fromLTWH(0, 0, 8, 8),
          bytes: bytes,
          broken: false,
        ),
      ],
    );
    Widget turner(FlowPage current, {FlowPage? previous, FlowPage? next}) =>
        Directionality(
          textDirection: TextDirection.ltr,
          child: ReaderPageTurner(
            current: current,
            previous: previous,
            next: next,
            style: testFlowStyle,
            onTurn: (_) {},
          ),
        );
    Future<void> decode() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }

    FlowImages? shared() =>
        tester.widget<FlowPageView>(find.byType(FlowPageView)).images;

    await tester.pumpWidget(turner(first, next: second));
    await decode();

    // Only the first page is on screen, the picture of the next is decoded.
    final images = shared();
    expect(images, isNotNull);
    final ready = images![bytes];
    expect(ready, isNotNull);

    await tester.pumpWidget(turner(second, previous: first));

    expect(shared(), same(images));
    expect(images[bytes], same(ready));
  });
}
