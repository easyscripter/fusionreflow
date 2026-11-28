import 'package:flow_render/flow_render.dart';
import 'package:flow_render/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

FlowPage _page(List<FlowPageItem> items) =>
    FlowPage(start: 0, end: 1, items: items, last: true);

void main() {
  testWidgets('keeps only the pictures of the shown pages, at their size', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final big = await makePng(400, 200);
      final other = await makePng(30, 30);
      final first = _page([
        FlowPictureItem(
          const Rect.fromLTWH(0, 0, 100, 50),
          bytes: big,
          broken: false,
        ),
      ]);
      final second = _page([
        FlowPictureItem(
          const Rect.fromLTWH(0, 0, 30, 30),
          bytes: other,
          broken: false,
        ),
      ]);
      final images = FlowImages();

      await images.show([first], 2);
      final decoded = images[big]!;
      expect(decoded.width, 200); // 100 dp at 2 px per dp, not 400
      expect(images[other], isNull);

      await images.show([second], 2);
      expect(images[big], isNull);
      expect(decoded.debugDisposed, isTrue);
      expect(images[other]!.width, 30); // never enlarged

      // A wider rectangle (a turned phone) decodes again.
      await images.show([first], 1);
      expect(images[big]!.width, 100);
      await images.show([first], 3);
      expect(images[big]!.width, 300);

      final last = images[big]!;
      images.dispose();
      expect(last.debugDisposed, isTrue);
    });
  });

  testWidgets('a decode that ends after the page is gone is dropped', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final png = await makePng(10, 10);
      final images = FlowImages();
      final loading = images.show([
        _page([
          FlowPictureItem(
            const Rect.fromLTWH(0, 0, 10, 10),
            bytes: png,
            broken: false,
          ),
        ]),
      ], 1);
      final emptied = images.show(const [], 1);
      await Future.wait([loading, emptied]);

      expect(images[png], isNull);
      images.dispose();
    });
  });

  testWidgets('two requests at once decode a picture once', (tester) async {
    await tester.runAsync(() async {
      final png = await makePng(10, 10);
      final page = _page([
        FlowPictureItem(
          const Rect.fromLTWH(0, 0, 10, 10),
          bytes: png,
          broken: false,
        ),
      ]);
      final images = FlowImages();
      var decoded = 0;
      images.addListener(() => decoded++);

      await Future.wait([
        images.show([page], 1),
        images.show([page], 1),
      ]);

      expect(decoded, 1);
      images.dispose();
    });
  });

  testWidgets('the page is read aloud', (tester) async {
    final semantics = tester.ensureSemantics();
    final pages = (await tester.runAsync(
      () => const FlowPaginator().paginate(
        section([para(2)]),
        const Size(360, 640),
        testStyle,
      ),
    ))!;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FlowPageView(page: pages.single, style: testStyle),
      ),
    );

    expect(find.bySemanticsLabel('слово слово'), findsOneWidget);
    semantics.dispose();
  });
}
