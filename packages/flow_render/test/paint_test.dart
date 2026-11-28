import 'dart:typed_data';

import 'package:flow_render/flow_render.dart';
import 'package:flow_render/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const _size = Size(360, 640);

/// The color of makePng.
const _picture = Color(0xFF336699);
const _background = Color(0xFFFFFFFF);

/// Paints [page] with its pictures and returns a reader of pixel colors.
Future<Color Function(Offset)> _paint(
  WidgetTester tester,
  FlowPage page,
) async {
  tester.view
    ..physicalSize = _size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final images = FlowImages();
  addTearDown(images.dispose);
  await tester.runAsync(() => images.show([page], 1));
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: ColoredBox(
          color: _background,
          child: FlowPageView(page: page, style: testStyle, images: images),
        ),
      ),
    ),
  );
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = (await tester.runAsync<ByteData>(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData();
    image.dispose();
    return data!;
  }))!;
  Color read(Offset at) {
    final i = (at.dy.floor() * _size.width.toInt() + at.dx.floor()) * 4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  }

  return read;
}

Future<FlowPage> _layout(WidgetTester tester, List<FlowBlock> blocks) async =>
    (await tester.runAsync(
      () => const FlowPaginator().paginate(section(blocks), _size, testStyle),
    ))!.first;

void main() {
  testWidgets('pictures in a line and in a cell fill their places', (
    tester,
  ) async {
    // Smaller than its place: it has to grow to fill it.
    final png = (await tester.runAsync(() => makePng(10, 10)))!;
    final other = (await tester.runAsync(() => makePng(12, 12)))!;
    final page = await _layout(tester, [
      FlowText([const FlowTextSpan('x '), FlowImageSpan(png, 2)]),
      FlowTable([
        [
          [FlowImageSpan(other, 2)],
        ],
      ]),
    ]);

    final color = await _paint(tester, page);

    final line = page.items.whereType<FlowLineItem>().single;
    final inLine = line.inlineImages.single.box.shift(
      Offset(line.rect.left, line.rect.top - line.top),
    );
    final cell = page.items.whereType<FlowRowItem>().single.cells.single;
    final inCell = cell.inlineImages.single.box.shift(cell.rect.topLeft);
    for (final box in [inLine, inCell]) {
      expect(color(box.center), _picture);
      expect(color(box.topLeft + const Offset(3, 3)), _picture);
      expect(color(box.bottomRight - const Offset(3, 3)), _picture);
    }
  });

  testWidgets('table rows share one line', (tester) async {
    const row = [
      [FlowTextSpan('а')],
    ];
    final page = await _layout(tester, [
      const FlowTable([row, row]),
    ]);
    final rows = page.items.whereType<FlowRowItem>().toList();

    final color = await _paint(tester, page);

    // A column of pixels inside the cell, around the border of the rows.
    final x = rows.first.rect.right - 20;
    final border = rows.last.rect.top;
    final lines = [
      for (var y = border - 3; y <= border + 3; y++)
        if (color(Offset(x, y)) != _background) y,
    ];
    expect(lines, hasLength(1));
    // The table is still closed above and below.
    expect(color(Offset(x, rows.first.rect.top)), isNot(_background));
    expect(color(Offset(x, rows.last.rect.bottom - 1)), isNot(_background));
  });
}
