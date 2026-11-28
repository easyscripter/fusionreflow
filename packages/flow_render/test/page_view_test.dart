import 'package:flow_render/flow_render.dart';
import 'package:flow_render/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const _size = Size(360, 640);

void main() {
  testWidgets('paints every kind of item and decodes pictures', (tester) async {
    final png = await tester.runAsync(() => makePng(30, 20));
    final s = section([
      const FlowText([FlowTextSpan('Заголовок')], role: FlowTextRole.heading),
      para(10),
      const FlowText([FlowTextSpan('пункт')], marker: '•'),
      FlowText([const FlowTextSpan('в строке '), FlowImageSpan(png!, 1)]),
      FlowImage(png),
      FlowImage(Uint8List.fromList([1, 2, 3])),
      const FlowRule(),
      const FlowTable([
        [
          [FlowTextSpan('а')],
          [FlowTextSpan('б')],
        ],
      ]),
    ]);
    final pages = await tester.runAsync(
      () => const FlowPaginator().paginate(s, _size, testStyle),
    );
    final page = pages!.first;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.fromSize(
          size: _size,
          child: FlowPageView(page: page, style: testStyle),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);

    // Another page replaces the old one; unmounting releases the images.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.fromSize(
          size: _size,
          child: const FlowPageView(
            page: FlowPage(start: 0, end: 0, items: [], last: true),
            style: testStyle,
          ),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
