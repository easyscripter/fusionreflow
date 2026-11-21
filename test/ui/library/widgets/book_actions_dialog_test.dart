import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/library/widgets/book_card.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/library_harness.dart';

void main() {
  final book = bookEntry(id: 'a', title: 'Пример книги', authors: ['А. Автор']);
  final reading = bookEntry(
    id: 'r',
    title: 'Читаемая',
    progress: 0.4,
    lastReadAt: DateTime.utc(2026, 2),
  );

  testWidgets('long press opens actions', (tester) async {
    await pumpLibrary(tester, books: [book]);

    await tester.longPress(find.byType(BookCard));
    await tester.pumpAndSettle();

    final dialog = find.byKey(const Key('book_actions'));
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('Пример книги')),
      findsWidgets, // the title and the cover
    );
    expect(
      find.descendant(of: dialog, matching: find.text('А. Автор')),
      findsOneWidget,
    );
    expect(find.text('Информация о книге'), findsOneWidget);
    expect(find.text('Удалить книгу'), findsOneWidget);
  });

  testWidgets('long press on continue reading opens the same menu', (
    tester,
  ) async {
    await pumpLibrary(tester, books: [reading]);

    await tester.longPress(find.byKey(const Key('continue_reading')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('book_actions')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('book_actions')),
        matching: find.text('Читаемая'),
      ),
      findsWidgets,
    );
  });

  testWidgets('tap still opens reader', (tester) async {
    await pumpLibrary(tester, books: [book]);

    await tester.tap(find.byType(BookCard));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reader_placeholder')), findsOneWidget);
  });

  testWidgets('close does nothing', (tester) async {
    final h = await pumpLibrary(tester, books: [book]);

    await tester.longPress(find.byType(BookCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('book_action_close')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('book_actions')), findsNothing);
    expect(find.byKey(const Key('library_screen')), findsOneWidget);
    expect(h.books.deleted, isEmpty);
  });

  testWidgets('details opens book card', (tester) async {
    await pumpLibrary(tester, books: [book]);

    await tester.longPress(find.byType(BookCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('book_action_details')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('book_details')), findsOneWidget);
    await tester.tap(find.byKey(const Key('book_back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library_screen')), findsOneWidget);
  });
}
