import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';

import '../../helpers/book_entry.dart';
import '../../helpers/library_harness.dart';
import '../../helpers/load_golden_fonts.dart';

// Pixel output differs between platforms, so CI skips this tag (see
// dart_test.yaml); it runs locally and in the QA pass.

DateTime _t(int n) => DateTime.utc(2026, 1, n);

final List<BookEntry> _books = [
  bookEntry(
    id: '1',
    title: 'Мастер и Маргарита',
    authors: const ['Михаил Булгаков'],
    progress: 0.34,
    lastReadAt: _t(20),
    addedAt: _t(1),
  ),
  bookEntry(
    id: '2',
    title: 'Дюна',
    authors: const ['Фрэнк Герберт'],
    format: BookFormat.fb2,
    sourceHash: '01',
    progress: 0.72,
    lastReadAt: _t(10),
    addedAt: _t(2),
  ),
  bookEntry(
    id: '3',
    title: 'Идиот',
    authors: const ['Фёдор Достоевский'],
    format: BookFormat.fb2Zip,
    sourceHash: '02',
    progress: 1,
    lastReadAt: _t(5),
    addedAt: _t(3),
  ),
  bookEntry(
    id: '4',
    title: 'The Pragmatic Programmer',
    authors: const ['Andrew Hunt', 'David Thomas'],
    sourceHash: '03',
    addedAt: _t(4),
  ),
  bookEntry(
    id: '5',
    title: '',
    authors: const [],
    sourceHash: '04',
    addedAt: _t(6),
  ),
];

Future<void> _expect(WidgetTester tester, String name) => expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('goldens/$name.png'),
);

void main() {
  setUpAll(loadGoldenFonts);

  testWidgets('library_phone_light', tags: 'golden', (tester) async {
    await pumpLibrary(tester, books: _books);
    await _expect(tester, 'library_phone_light');
  });

  testWidgets('library_phone_dark', tags: 'golden', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpLibrary(tester, books: _books);
    await _expect(tester, 'library_phone_dark');
  });

  testWidgets('library_empty_phone_light', tags: 'golden', (tester) async {
    await pumpLibrary(tester);
    await _expect(tester, 'library_empty_phone_light');
  });

  testWidgets('library_tablet_light', tags: 'golden', (tester) async {
    await pumpLibrary(tester, books: _books, size: const Size(820, 1180));
    await _expect(tester, 'library_tablet_light');
  });

  testWidgets('library_importing_phone_light', tags: 'golden', (tester) async {
    final h = await pumpLibrary(
      tester,
      books: _books,
      picked: const ImportSource(
        uri: 'u',
        name: 'Война и мир.epub',
        format: BookFormat.epub,
      ),
    );
    await startImport(tester);
    h.imports.current.add(const ImportUpdate.progress(done: 1, total: 3));
    await settleImport(tester);
    await _expect(tester, 'library_importing_phone_light');
  });

  testWidgets('import_pdf_later_phone_light', tags: 'golden', (tester) async {
    final h = await pumpLibrary(
      tester,
      picked: const ImportSource(
        uri: 'u',
        name: 'book.pdf',
        format: BookFormat.pdf,
        sizeBytes: 19293798,
      ),
    );
    await startImport(tester);
    h.imports.current.add(const ImportUpdate.failed(ImportFailure.pdfNotYet));
    await settleImport(tester);
    await tester.pumpAndSettle();
    await _expect(tester, 'import_pdf_later_phone_light');
  });
}
