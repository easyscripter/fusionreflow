import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/library/widgets/book_card.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/library_harness.dart';

DateTime _t(int n) => DateTime.utc(2026, 1, n);

List<String> _grid(WidgetTester tester) => [
  for (final e in find.byType(BookCard).evaluate())
    (e.widget as BookCard).book.id,
];

Future<void> _choose(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(const Key('sort_menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sorting works end to end on the whole screen', (tester) async {
    final h = await pumpLibrary(
      tester,
      books: [
        bookEntry(id: 'c', title: 'В', authors: const ['Яна'], addedAt: _t(3)),
        bookEntry(id: 'a', title: 'Б', authors: const ['Анна'], addedAt: _t(2)),
        bookEntry(
          id: 'b',
          title: 'А',
          authors: const ['Борис'],
          addedAt: _t(1),
        ),
      ],
    );
    expect(_grid(tester), ['c', 'a', 'b']);

    await _choose(tester, 'sort_title');
    expect(find.text('Название'), findsWidgets);
    expect(_grid(tester), ['b', 'a', 'c']);

    await _choose(tester, 'sort_author');
    expect(_grid(tester), ['a', 'b', 'c']);

    // A live update keeps the chosen order.
    h.books.emit([
      ...h.books.books,
      bookEntry(
        id: 'd',
        title: 'Г',
        authors: const ['Аркадий'],
        addedAt: _t(9),
      ),
    ]);
    await tester.pumpAndSettle();
    expect(_grid(tester), ['a', 'd', 'b', 'c']);
    expect(find.text('Автор'), findsWidgets);
  });

  testWidgets('sort chip stays with a single book', (tester) async {
    await pumpLibrary(tester, books: [bookEntry()]);

    expect(find.byKey(const Key('sort_menu')), findsOneWidget);
  });

  testWidgets('sorting survives a visit to another tab', (tester) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(id: 'a', title: 'Б', addedAt: _t(2)),
        bookEntry(id: 'b', title: 'А', addedAt: _t(1)),
      ],
    );
    await _choose(tester, 'sort_title');

    await tester.tap(find.text('Закладки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Библиотека'));
    await tester.pumpAndSettle();

    expect(_grid(tester), ['b', 'a']);
  });

  testWidgets('sorting survives opening a book and coming back', (
    tester,
  ) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(id: 'a', title: 'Б', addedAt: _t(2)),
        bookEntry(id: 'b', title: 'А', addedAt: _t(1)),
      ],
    );
    await _choose(tester, 'sort_title');

    await tester.tap(find.byType(BookCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Назад'));
    await tester.pumpAndSettle();

    expect(find.text('Название'), findsWidgets);
    expect(_grid(tester), ['b', 'a']);
    // And it still reacts afterwards.
    await _choose(tester, 'sort_recent');
    expect(_grid(tester), ['a', 'b']);
  });
}
