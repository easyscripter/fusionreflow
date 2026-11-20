import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/library/widgets/add_book_sheet.dart';

import '../../../helpers/library_harness.dart';

void main() {
  testWidgets('add opens a sheet with a single file row', (tester) async {
    final h = await pumpLibrary(tester);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();

    expect(find.byType(AddBookSheet), findsOneWidget);
    expect(find.text('Добавить книгу'), findsWidgets);
    expect(find.text('Выбрать файл'), findsOneWidget);
    expect(find.text('EPUB, FB2, FB2.ZIP'), findsOneWidget);
    expect(find.text('Выбрать папку'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('pick_file'))).height,
      greaterThanOrEqualTo(68),
    );
    expect(h.imports.pickCalls, 0);
  });

  testWidgets('tapping the row closes the sheet and picks a file', (
    tester,
  ) async {
    final h = await pumpLibrary(tester, picked: null);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick_file')));
    await tester.pumpAndSettle();

    expect(find.byType(AddBookSheet), findsNothing);
    expect(h.imports.pickCalls, 1);
  });

  testWidgets('dismissing the sheet does not pick', (tester) async {
    final h = await pumpLibrary(tester);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(195, 60));
    await tester.pumpAndSettle();

    expect(find.byType(AddBookSheet), findsNothing);
    expect(h.imports.pickCalls, 0);
  });

  testWidgets('sheet covers the navigation bar and blocks it', (tester) async {
    await pumpLibrary(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();

    expect(tester.getRect(find.byType(AddBookSheet)).bottom, 844);
    // The tap lands on the scrim, not on the bar: no navigation happens.
    await tester.tap(find.text('Закладки'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bookmarks_screen')), findsNothing);
    expect(find.byKey(const Key('library_screen')), findsOneWidget);
  });

  testWidgets('sheet shows the footnote', (tester) async {
    await pumpLibrary(tester);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();

    final note = find.text(
      'Файлы остаются на месте, приложение запоминает ссылки на них. '
      'Сохранять копии можно в настройках.',
    );
    expect(note, findsOneWidget);
    expect(tester.widget<Text>(note).style?.fontSize, 12.5);
  });
}
