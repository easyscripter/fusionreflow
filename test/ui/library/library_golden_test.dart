import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';

import '../../helpers/book_entry.dart';
import '../../helpers/golden.dart';
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

void main() {
  setUpAll(loadGoldenFonts);

  goldenTest('library_phone_light', (tester) async {
    await pumpLibrary(tester, books: _books);
    await expectGolden('library_phone_light');
  });

  goldenTest('library_phone_dark', (tester) async {
    await pumpLibrary(tester, books: _books);
    await expectGolden('library_phone_dark');
  }, dark: true);

  goldenTest('library_empty_phone_light', (tester) async {
    await pumpLibrary(tester);
    await expectGolden('library_empty_phone_light');
  });

  goldenTest('library_tablet_light', (tester) async {
    await pumpLibrary(tester, books: _books, size: const Size(820, 1180));
    await expectGolden('library_tablet_light');
  });

  goldenTest('library_importing_phone_light', (tester) async {
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
    await expectGolden('library_importing_phone_light');
  });

  goldenTest('import_pdf_later_phone_light', (tester) async {
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
    await expectGolden('import_pdf_later_phone_light');
  });

  goldenTest('add_book_sheet_phone_dark', (tester) async {
    await pumpLibrary(tester, books: _books);
    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();
    await expectGolden('add_book_sheet_phone_dark');
  }, dark: true);

  goldenTest('library_empty_phone_dark', (tester) async {
    await pumpLibrary(tester);
    await expectGolden('library_empty_phone_dark');
  }, dark: true);
}
