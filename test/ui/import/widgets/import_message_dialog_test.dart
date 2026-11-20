import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';

import '../../../helpers/library_harness.dart';

const _pdf = ImportSource(
  uri: 'content://b',
  name: 'book.pdf',
  format: BookFormat.pdf,
  sizeBytes: 19293798,
);

/// Pumps the library, starts an import of [source] and fails it.
Future<LibraryHarness> _fail(
  WidgetTester tester,
  ImportFailure failure, {
  ImportSource source = epubSource,
  Size size = const Size(390, 844),
}) async {
  final h = await pumpLibrary(tester, picked: source, size: size);
  await startImport(tester);
  h.imports.current.add(ImportUpdate.failed(failure));
  await settleImport(tester);
  await tester.pumpAndSettle();
  return h;
}

/// The card's own box (the Dialog widget itself fills the screen).
Finder _card() => find.descendant(
  of: find.byType(Dialog),
  matching: find.byType(SingleChildScrollView),
);

void main() {
  testWidgets('each failure shows its card', (tester) async {
    final cases = <ImportFailure, (String, List<String>)>{
      ImportFailure.pdfNotYet: (
        'PDF будет доступен позже',
        ['Выбрать EPUB или FB2', 'Понятно'],
      ),
      ImportFailure.unsupportedFormat: (
        'Этот формат не поддерживается',
        ['Понятно'],
      ),
      ImportFailure.unreadable: (
        'Не удалось открыть файл',
        ['Выбрать другой файл'],
      ),
      ImportFailure.noAccess: ('Нет доступа к файлу', ['Выбрать файл']),
      ImportFailure.cancelled: (
        'Добавление отменено',
        ['Повторить', 'Закрыть'],
      ),
    };
    for (final MapEntry(key: failure, value: (title, buttons))
        in cases.entries) {
      await _fail(tester, failure);
      expect(find.text(title), findsOneWidget, reason: '$failure');
      for (final label in buttons) {
        expect(find.text(label), findsOneWidget, reason: '$failure $label');
      }
      // New scope for the next case.
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('pdf card shows file name and size', (tester) async {
    await _fail(tester, ImportFailure.pdfNotYet, source: _pdf);
    expect(find.text('book.pdf'), findsOneWidget);
    expect(
      find.text('PDF · 18,4 МБ · в библиотеку не добавлен'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
    await _fail(
      tester,
      ImportFailure.pdfNotYet,
      source: const ImportSource(
        uri: 'u',
        name: 'x.pdf',
        format: BookFormat.pdf,
      ),
    );
    expect(find.text('PDF · в библиотеку не добавлен'), findsOneWidget);
  });

  testWidgets('fullscreen on phone, dialog on tablet', (tester) async {
    await _fail(tester, ImportFailure.unsupportedFormat);
    expect(tester.getSize(_card()), const Size(390, 844));

    await tester.pumpWidget(const SizedBox());
    await _fail(
      tester,
      ImportFailure.unsupportedFormat,
      size: const Size(820, 1180),
    );
    final size = tester.getSize(_card());
    expect(size.width, lessThanOrEqualTo(420));
    expect(size.height, lessThan(1180));
  });

  testWidgets('cancelled retry calls retry', (tester) async {
    final h = await _fail(tester, ImportFailure.cancelled);

    await tester.tap(find.text('Повторить'));
    await settleImport(tester);

    expect(h.imports.converted, [epubSource, epubSource]);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('close dismisses and keeps the library', (tester) async {
    await _fail(tester, ImportFailure.cancelled);

    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.byKey(const Key('importing_book')), findsNothing);
  });

  testWidgets('pick another file starts a new pick', (tester) async {
    final h = await _fail(tester, ImportFailure.unreadable);
    expect(h.imports.pickCalls, 1);

    await tester.tap(find.text('Выбрать другой файл'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(h.imports.pickCalls, 2);
  });

  testWidgets('dismissing by the barrier acts like close', (tester) async {
    await _fail(
      tester,
      ImportFailure.unsupportedFormat,
      size: const Size(820, 1180),
    );

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('large system font does not overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _fail(tester, ImportFailure.pdfNotYet, source: _pdf);

    expect(tester.takeException(), isNull);
    expect(find.text('PDF будет доступен позже'), findsOneWidget);
  });
}
