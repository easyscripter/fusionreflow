import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/library/widgets/book_card.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/library_harness.dart';

void main() {
  final book = bookEntry(id: 'a', title: 'Пример книги');

  Future<void> askDelete(WidgetTester tester) async {
    await tester.longPress(find.byType(BookCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('book_action_delete')));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel keeps the book', (tester) async {
    final h = await pumpLibrary(tester, books: [book]);

    await askDelete(tester);
    expect(find.textContaining('«Пример книги» исчезнет'), findsOneWidget);
    await tester.tap(find.byKey(const Key('delete_cancel')));
    await tester.pumpAndSettle();

    expect(h.books.deleted, isEmpty);
    expect(find.byType(BookCard), findsOneWidget);
  });

  testWidgets('confirm deletes and shows snackbar', (tester) async {
    final h = await pumpLibrary(tester, books: [book]);

    await askDelete(tester);
    await tester.tap(find.byKey(const Key('delete_confirm')));
    await tester.pumpAndSettle();

    expect(h.books.deleted, ['a']);
    expect(find.text('Книга удалена'), findsOneWidget);
    expect(find.byType(BookCard), findsNothing);
  });

  testWidgets('delete failure shows snackbar', (tester) async {
    final h = await pumpLibrary(tester, books: [book]);
    h.books.deleteError = Exception('boom');

    await askDelete(tester);
    await tester.tap(find.byKey(const Key('delete_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось удалить книгу'), findsOneWidget);
    expect(find.byType(BookCard), findsOneWidget);
  });

  testWidgets('dialog looks like the mockup', (tester) async {
    await pumpLibrary(tester, books: [book]);

    await askDelete(tester);

    final surface = find
        .ancestor(
          of: find.text('Удалить книгу?'),
          matching: find.byType(Material),
        )
        .first;
    expect(tester.getSize(surface).width, 326);
    final style = DefaultTextStyle.of(
      tester.element(find.text('Удалить книгу?')),
    ).style;
    expect(style.fontSize, 20);
    expect(style.fontWeight, const FontWeight(650));
  });

  testWidgets('confirm after the library is gone does nothing', (tester) async {
    final h = await pumpLibrary(tester, books: [book]);

    await askDelete(tester);
    h.books.emitError(Exception('stream failed'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_confirm')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('untitled book in message', (tester) async {
    await pumpLibrary(
      tester,
      books: [bookEntry(id: 'a', title: '')],
    );

    await askDelete(tester);

    expect(find.textContaining('«Без названия» исчезнет'), findsOneWidget);
  });
}
