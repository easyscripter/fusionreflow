@Tags(['golden'])
library;

import 'package:flow_render/flow_render.dart';
import 'package:flow_render/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';
import 'load_fonts.dart';

// Pixel output differs between platforms, so CI skips this tag (see
// dart_test.yaml); run it locally and in the QA pass.

const _phone = Size(390, 844);
const _lightStyle = FlowStyle(
  fontFamily: 'Literata',
  codeFontFamily: 'JetBrainsMono',
  fontSize: 18,
  lineHeight: 1.56,
  padding: EdgeInsets.symmetric(horizontal: 24),
  justify: true,
  textColor: Color(0xFF1D1F23),
  mutedColor: Color(0xFF565A75),
  accentColor: Color(0xFF4A3FD0),
);
const _darkStyle = FlowStyle(
  fontFamily: 'Literata',
  codeFontFamily: 'JetBrainsMono',
  fontSize: 18,
  lineHeight: 1.56,
  padding: EdgeInsets.symmetric(horizontal: 24),
  justify: true,
  textColor: Color(0xFFD7DBE2),
  mutedColor: Color(0xFFA0A6CC),
  accentColor: Color(0xFFA99BFF),
);

const _text =
    'Он вышел на крыльцо и долго смотрел на дорогу, по которой утром уехала '
    'повозка с последними вещами. Дом за спиной опустел и стал непривычно '
    'тихим.';

Future<void> _pump(
  WidgetTester tester,
  FlowSection section,
  FlowStyle style,
  Color background, {
  Size size = _phone,
}) async {
  final pages = (await tester.runAsync(
    () => const FlowPaginator().paginate(section, size, style),
  ))!;
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        child: ColoredBox(
          color: background,
          child: FlowPageView(page: pages.first, style: style),
        ),
      ),
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pump();
}

Future<FlowSection> _sample() async {
  final png = await makePng(160, 90);
  return FlowSection([
    const FlowText([FlowTextSpan('Глава третья')], role: FlowTextRole.heading),
    const FlowText([FlowTextSpan(_text)]),
    const FlowText([
      FlowTextSpan('Слово '),
      FlowTextSpan('жирное', bold: true),
      FlowTextSpan(', '),
      FlowTextSpan('курсив', italic: true),
      FlowTextSpan(' и '),
      FlowTextSpan('ссылка', link: true),
      FlowTextSpan('1', link: true, script: FlowScript.sup),
      FlowTextSpan(' в тексте.'),
    ]),
    const FlowText([FlowTextSpan('Первый пункт списка')], marker: '•'),
    const FlowText([FlowTextSpan('Второй пункт списка')], marker: '2.'),
    const FlowText([FlowTextSpan('Цитата из книги')], indent: 1),
    const FlowText([FlowTextSpan('final x = 42;')], role: FlowTextRole.code),
    FlowImage(png),
    const FlowText([
      FlowTextSpan('Подпись к рисунку'),
    ], role: FlowTextRole.caption),
    const FlowTable([
      [
        [FlowTextSpan('Год')],
        [FlowTextSpan('Событие')],
      ],
      [
        [FlowTextSpan('1812')],
        [FlowTextSpan('Отечественная война')],
      ],
    ]),
    const FlowRule(),
  ]);
}

void main() {
  setUpAll(loadFonts);

  testWidgets('page_golden_light', (tester) async {
    await _pump(
      tester,
      (await tester.runAsync(_sample))!,
      _lightStyle,
      const Color(0xFFFDFDFB),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/page_light.png'),
    );
  });

  testWidgets('page_golden_dark', (tester) async {
    await _pump(
      tester,
      (await tester.runAsync(_sample))!,
      _darkStyle,
      const Color(0xFF0C0F22),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/page_dark.png'),
    );
  });

  testWidgets('bold_is_visible', (tester) async {
    await _pump(
      tester,
      const FlowSection([
        FlowText([FlowTextSpan('Обычный текст и жирный текст')]),
        FlowText([FlowTextSpan('Обычный текст и жирный текст', bold: true)]),
      ]),
      _lightStyle,
      const Color(0xFFFDFDFB),
      size: const Size(390, 120),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/bold.png'),
    );
  });

  testWidgets('soft_hyphen_not_visible', (tester) async {
    for (final width in [280.0, 360.0]) {
      await _pump(
        tester,
        const FlowSection([
          FlowText([
            FlowTextSpan(
              'Пред­ставле­ние о со­бытии рас­про­стра­ни­лось '
              'по го­ро­ду бы­стро и неожи­данно.',
            ),
          ]),
        ]),
        _lightStyle,
        const Color(0xFFFDFDFB),
        size: Size(width, 160),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/soft_hyphen_${width.toInt()}.png'),
      );
    }
  });
}
