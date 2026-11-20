import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/routing/app_routes.dart';

import '../../helpers/book_entry.dart';
import '../../helpers/fake_book_repository.dart';
import '../../helpers/golden.dart';
import '../../helpers/load_golden_fonts.dart';
import '../../helpers/pump_app.dart';

// Pixel output differs between platforms, so CI skips this tag (see
// dart_test.yaml); it runs locally and in the QA pass.

const _description =
    'Роман о визите гостя в большой город и о судьбе писателя, которого '
    'называют Автором. Описание взято из метаданных файла.\n\n'
    'Действие разворачивается в двух временах. Линии сходятся к одному '
    'вечеру и к судьбе героини, готовой на всё ради любимого человека.\n\n'
    'Книгу читают как сатиру, как притчу и как историю любви.';

final BookEntry _full = bookEntry(
  id: 'x',
  title: 'Пример книги',
  authors: const ['А. Автор'],
  progress: 0.34,
  addedAt: DateTime.utc(2026, 11, 9),
  language: 'ru',
  description: _description,
  sourceSize: 1887437,
);

final BookEntry _empty = bookEntry(
  id: 'x',
  title: 'Конспект лекций',
  authors: const [],
  sourceHash: '03',
  addedAt: DateTime.utc(2026, 11, 9),
  sourceSize: 400000,
);

Future<void> _open(
  WidgetTester tester,
  BookEntry book, {
  Size size = const Size(390, 844),
}) => pumpApp(
  tester,
  size: size,
  books: FakeBookRepository([book]),
  location: AppRoutes.bookDetailsOf('x'),
);

void main() {
  setUpAll(loadGoldenFonts);

  goldenTest('book_card_phone_light', (tester) async {
    await _open(tester, _full);
    await expectGolden('book_card_phone_light');
  });

  goldenTest('book_card_phone_dark', (tester) async {
    await _open(tester, _full);
    await expectGolden('book_card_phone_dark');
  }, dark: true);

  goldenTest('book_card_empty_phone_light', (tester) async {
    await _open(tester, _empty);
    await expectGolden('book_card_empty_phone_light');
  });

  goldenTest('book_description_phone_dark', (tester) async {
    await _open(tester, _full);
    await tester.tap(find.byKey(const Key('book_read_more')));
    await tester.pumpAndSettle();
    await expectGolden('book_description_phone_dark');
  }, dark: true);

  goldenTest('book_card_tablet_light', (tester) async {
    await _open(tester, _full, size: const Size(820, 1180));
    await expectGolden('book_card_tablet_light');
  });
}
