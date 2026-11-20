import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_source.dart';

import 'fake_book_repository.dart';
import 'fake_import_repository.dart';
import 'pump_app.dart';

/// Source an import test "picks".
const epubSource = ImportSource(
  uri: 'content://a',
  name: 'a.epub',
  format: BookFormat.epub,
);

/// Fakes behind a pumped library.
typedef LibraryHarness = ({
  FakeBookRepository books,
  FakeImportRepository imports,
});

/// Pumps the app on the library with [books] and fake repositories.
Future<LibraryHarness> pumpLibrary(
  WidgetTester tester, {
  List<BookEntry> books = const [],
  Size size = const Size(390, 844),
  ImportSource? picked = epubSource,
  Exception? watchError,
}) async {
  final bookRepo = FakeBookRepository(books)..watchError = watchError;
  final importRepo = FakeImportRepository(picked: picked);
  await pumpApp(tester, size: size, books: bookRepo, imports: importRepo);
  return (books: bookRepo, imports: importRepo);
}

/// Taps "Add", then "Choose file" in the sheet, and lets the import start (no
/// settle afterwards: the spinner never stops).
Future<void> startImport(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('add_book')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('pick_file')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Lets queued events and animations run without waiting for a spinner.
Future<void> settleImport(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
