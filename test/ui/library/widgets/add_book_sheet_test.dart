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
    // A tap on the scrim, just inside its top-left corner.
    await tester.tapAt(
      tester.getTopLeft(find.byType(ModalBarrier).last) + const Offset(10, 10),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddBookSheet), findsNothing);
    expect(h.imports.pickCalls, 0);
  });

  testWidgets('sheet covers the navigation bar and blocks it', (tester) async {
    await pumpLibrary(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byType(AddBookSheet)).bottom,
      tester.getSize(find.byType(MaterialApp)).height,
    );
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
      'Книга сохраняется в приложении, '
      'исходный файл после добавления не нужен.',
    );
    expect(note, findsOneWidget);
    expect(tester.widget<Text>(note).style?.fontSize, 12.5);
  });

  testWidgets('sheet works at 200% font and has semantics roles', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final h = await pumpLibrary(tester, picked: null);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSemantics(find.text('Добавить книгу').last),
      matchesSemantics(label: 'Добавить книгу', isHeader: true),
    );
    expect(
      tester.getSemantics(find.byKey(const Key('pick_file'))),
      matchesSemantics(
        hasTapAction: true,
        isButton: true,
        isFocusable: true,
        hasFocusAction: true,
        label: 'Выбрать файл\nEPUB, FB2, FB2.ZIP',
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('pick_file')));
    await tester.tap(find.byKey(const Key('pick_file')));
    await tester.pumpAndSettle();
    expect(h.imports.pickCalls, 1);
    semantics.dispose();
  });
}
