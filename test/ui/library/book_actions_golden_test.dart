import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/ui/library/widgets/book_card.dart';

import '../../helpers/book_entry.dart';
import '../../helpers/golden.dart';
import '../../helpers/library_harness.dart';
import '../../helpers/load_golden_fonts.dart';

// Pixel output differs between platforms, so CI skips this tag (see
// dart_test.yaml); it runs locally and in the QA pass.

final List<BookEntry> _books = [
  bookEntry(
    id: '1',
    title: 'Пример книги',
    authors: const ['А. Автор'],
    sourceHash: '01',
  ),
  bookEntry(id: '2', title: 'Другая книга', sourceHash: '02'),
];

Future<void> _openActions(WidgetTester tester) async {
  await pumpLibrary(tester, books: _books);
  await tester.longPress(find.byType(BookCard).first);
  await tester.pumpAndSettle();
}

Future<void> _openDelete(WidgetTester tester) async {
  await _openActions(tester);
  await tester.tap(find.byKey(const Key('book_action_delete')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadGoldenFonts);

  goldenTest('book_actions_phone_light', (tester) async {
    await _openActions(tester);
    await expectGolden('book_actions_phone_light');
  });

  goldenTest('book_actions_phone_dark', (tester) async {
    await _openActions(tester);
    await expectGolden('book_actions_phone_dark');
  }, dark: true);

  goldenTest('book_delete_phone_light', (tester) async {
    await _openDelete(tester);
    await expectGolden('book_delete_phone_light');
  });

  goldenTest('book_delete_phone_dark', (tester) async {
    await _openDelete(tester);
    await expectGolden('book_delete_phone_dark');
  }, dark: true);
}
