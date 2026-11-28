import 'dart:async';

import 'package:flow_render/flow_render.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/routing/app_routes.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';
import '../../../helpers/golden.dart';
import '../../../helpers/load_golden_fonts.dart';
import '../../../helpers/pump_app.dart';

// Pixel output differs between platforms, so CI skips this tag (see
// dart_test.yaml); it runs locally and in the QA pass. Compare with the
// design: reader, reader-states, reader-landscape.

const _id = 'b1';

const _first =
    'Однажды весною, в час небывало жаркого заката, на набережной появились '
    'два гражданина. Первый из них, одетый в летнюю серенькую пару, был '
    'маленького роста, упитан и лыс, свою приличную шляпу нёс в руке, а на '
    'хорошо выбритом лице его помещались очки в чёрной роговой оправе.';
const _second =
    'Второй — плечистый, рыжеватый молодой человек в заломленной на затылок '
    'клетчатой кепке — был в ковбойке и в чёрных тапочках. Они долго шли '
    'вдоль воды и молчали, потому что обоим было нечего сказать.';

FlowBook _book() => FlowBook('Книга', [
  FlowSection([
    const FlowText([FlowTextSpan('Глава 1')], role: FlowTextRole.heading),
    for (var i = 0; i < 4; i++) ...[
      const FlowText([FlowTextSpan(_first)]),
      const FlowText([FlowTextSpan(_second)]),
    ],
    const FlowText([
      FlowTextSpan('Слово '),
      FlowTextSpan('жирное', bold: true),
      FlowTextSpan(', '),
      FlowTextSpan('курсив', italic: true),
      FlowTextSpan(' и ссылка', link: true),
      FlowTextSpan('1', link: true, script: FlowScript.sup),
    ]),
    const FlowText([FlowTextSpan('Первый пункт')], marker: '•'),
    const FlowText([FlowTextSpan('Второй пункт')], marker: '2.'),
    const FlowText([FlowTextSpan('Цитата')], indent: 1),
    const FlowText([FlowTextSpan('print(1)')], role: FlowTextRole.code),
    const FlowTable([
      [
        [FlowTextSpan('Год')],
        [FlowTextSpan('Событие')],
      ],
      [
        [FlowTextSpan('1812')],
        [FlowTextSpan('Война')],
      ],
    ]),
  ], title: 'Никогда не разговаривайте с неизвестными'),
  const FlowSection([
    FlowText([FlowTextSpan('Вторая')]),
  ], title: 'Вторая'),
]);

FakeBookRepository _repo() =>
    FakeBookRepository([bookEntry(id: _id)])..opened[_id] = _book();

Future<void> _open(
  WidgetTester tester,
  FakeBookRepository repo, {
  Size size = const Size(390, 844),
  bool settle = true,
}) async {
  await loadGoldenFonts();
  await pumpApp(
    tester,
    books: repo,
    size: size,
    location: AppRoutes.readerOf(_id),
    settle: settle,
  );
}

void main() {
  goldenTest('reader_page_light', (tester) async {
    await _open(tester, _repo());
    await expectGolden('reader_page_light');
  });

  goldenTest('reader_page_dark', (tester) async {
    await _open(tester, _repo());
    await expectGolden('reader_page_dark');
  }, dark: true);

  goldenTest('reader_landscape_light', (tester) async {
    await _open(tester, _repo(), size: const Size(844, 390));
    await expectGolden('reader_landscape_light');
  });

  goldenTest('reader_loading', (tester) async {
    final repo = _repo()..openGate = Completer<void>();
    await _open(tester, repo, settle: false);
    await expectGolden('reader_loading');
  });

  goldenTest('reader_not_found', (tester) async {
    await _open(tester, FakeBookRepository([bookEntry(id: _id)]));
    await expectGolden('reader_not_found');
  });
}
