import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/services/document_channel.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_update.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';
import 'package:fusionreflow/ui/import/widgets/importing_book_card.dart';
import 'package:fusionreflow/ui/library/widgets/book_card.dart';
import 'package:fusionreflow/ui/library/widgets/continue_reading_card.dart';
import 'package:fusionreflow/ui/library/widgets/library_empty_view.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_screen.dart';
import 'package:fusionreflow/ui/spikes/widgets/hyphen_spike_screen.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/library_harness.dart';
import '../../../helpers/open_hyphen_spike.dart';

DateTime _t(int n) => DateTime.utc(2026, 1, n);

Finder _inCard(String text) =>
    find.descendant(of: find.byType(BookCard), matching: find.text(text));

void main() {
  testWidgets('shows empty state', (tester) async {
    await pumpLibrary(tester);

    expect(find.byType(LibraryEmptyView), findsOneWidget);
    expect(find.byKey(const Key('add_book')), findsOneWidget);
    expect(find.text('Здесь пока нет книг'), findsOneWidget);
  });

  testWidgets('shows books, count and continue reading', (tester) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(id: '1', title: 'Первая', addedAt: _t(1)),
        bookEntry(id: '2', title: 'Вторая', addedAt: _t(2)),
        bookEntry(id: '3', title: 'Третья', addedAt: _t(3)),
        bookEntry(id: '4', title: 'Читаемая', progress: 0.3, lastReadAt: _t(4)),
      ],
    );

    expect(find.byType(ContinueReadingCard), findsOneWidget);
    expect(find.byType(BookCard), findsNWidgets(3));
    expect(find.text('4 книги'), findsOneWidget);
    expect(find.text('Продолжить чтение'), findsOneWidget);
    expect(find.text('Author · 30%'), findsOneWidget);
  });

  testWidgets('card labels new, percent and finished', (tester) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(id: 'hero', progress: 0.1, lastReadAt: _t(9)),
        bookEntry(id: 'new', title: 'N'),
        bookEntry(
          id: 'mid',
          title: 'M',
          format: BookFormat.fb2,
          progress: 0.72,
          lastReadAt: _t(2),
        ),
        bookEntry(
          id: 'done',
          title: 'D',
          format: BookFormat.fb2Zip,
          progress: 1,
          lastReadAt: _t(3),
        ),
      ],
    );

    expect(_inCard('Новая · EPUB'), findsOneWidget);
    expect(_inCard('72% · FB2'), findsOneWidget);
    expect(_inCard('Прочитана · FB2.ZIP'), findsOneWidget);
  });

  testWidgets('book without authors and title', (tester) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(title: '', authors: const ['']),
      ],
    );

    expect(_inCard('Без названия'), findsWidgets);
    expect(_inCard(''), findsNothing);
    expect(find.text('Author'), findsNothing);
  });

  testWidgets('several authors are joined', (tester) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(authors: const ['Анна', 'Борис']),
      ],
    );

    expect(_inCard('Анна, Борис'), findsWidgets);
  });

  for (final (locale, expected) in [
    ('ru', 'Без названия'),
    ('en', 'Untitled'),
  ]) {
    testWidgets('untitled book in continue reading ($locale)', (tester) async {
      await pumpLibrary(
        tester,
        books: [bookEntry(title: '', progress: 0.5, lastReadAt: _t(2))],
      );
      if (locale == 'en') {
        tester.platformDispatcher.localesTestValue = const [Locale('en')];
        await tester.pumpAndSettle();
      }

      expect(
        find.descendant(
          of: find.byType(ContinueReadingCard),
          matching: find.text(expected),
        ),
        findsWidgets,
      );
    });
  }

  testWidgets('phone sort menu changes order', (tester) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(id: 'a', title: 'Б', addedAt: _t(3)),
        bookEntry(id: 'b', title: 'А', addedAt: _t(2)),
        bookEntry(id: 'c', title: 'В', addedAt: _t(1)),
      ],
    );
    String first() =>
        tester.widget<BookCard>(find.byType(BookCard).first).book.title;
    expect(first(), 'Б');

    await tester.tap(find.byKey(const Key('sort_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sort_title')));
    await tester.pumpAndSettle();

    expect(first(), 'А');
    // The chip shows the chosen order; tapping it again closes the menu.
    expect(find.text('Название'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sort_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sort_menu')));
    await tester.pumpAndSettle();
  });

  testWidgets('sort chip matches the design', (tester) async {
    await pumpLibrary(tester, books: [bookEntry()]);

    final chip = find.byKey(const Key('sort_menu'));
    expect(tester.getSize(chip).height, 36);
    Finder asset(WidgetPredicate p) =>
        find.descendant(of: chip, matching: find.byWidgetPredicate(p));
    expect(
      asset((w) => w is AppIcon && w.asset == AppIcons.sort && w.size == 16),
      findsOneWidget,
    );
    expect(
      asset(
        (w) => w is AppIcon && w.asset == AppIcons.chevronDown && w.size == 14,
      ),
      findsOneWidget,
    );
    expect(find.text('Недавние'), findsOneWidget);
  });

  testWidgets('sort chip is a button for accessibility', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpLibrary(tester, books: [bookEntry()]);

    expect(
      tester.getSemantics(find.byKey(const Key('sort_menu'))),
      matchesSemantics(
        label: 'Недавние',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('a failing picker shows a snackbar', (tester) async {
    final h = await pumpLibrary(tester);
    h.imports.pickError = PlatformException(
      code: DocumentChannel.errorPickFailed,
    );

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick_file')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Не удалось открыть выбор файла'), findsOneWidget);
    expect(h.imports.pickCalls, 1);
  });

  testWidgets('tablet shows sort chips and four columns', (tester) async {
    await pumpLibrary(
      tester,
      size: const Size(820, 1180),
      books: [
        for (var i = 0; i < 6; i++)
          bookEntry(id: '$i', title: 'T$i', addedAt: _t(i + 1)),
      ],
    );

    expect(find.byType(ChoiceChip), findsNWidgets(3));
    final firstRow = tester.getTopLeft(find.byType(BookCard).first).dy;
    final inFirstRow = find
        .byType(BookCard)
        .evaluate()
        .where(
          (e) => tester.getTopLeft(find.byWidget(e.widget)).dy == firstRow,
        );
    expect(inFirstRow, hasLength(4));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Название'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Название'))
          .selected,
      isTrue,
    );
  });

  testWidgets('error shows retry', (tester) async {
    final h = await pumpLibrary(tester, watchError: Exception('boom'));
    expect(find.byKey(const Key('library_error')), findsOneWidget);

    h.books.watchError = null;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();

    expect(h.books.watchCalls, 2);
    expect(find.byKey(const Key('library_error')), findsNothing);
    expect(find.byType(LibraryEmptyView), findsOneWidget);
  });

  testWidgets('tap book opens reader', (tester) async {
    await pumpLibrary(
      tester,
      books: [
        bookEntry(id: 'hero', progress: 0.1, lastReadAt: _t(9)),
        bookEntry(id: 'mid', title: 'M', progress: 0.72, lastReadAt: _t(2)),
      ],
    );

    await tester.tap(find.byType(BookCard));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.byType(ReaderScreen), findsOneWidget);

    await tester.tap(find.text('Назад'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library_screen')), findsOneWidget);
  });

  testWidgets('tap continue reading opens its book', (tester) async {
    await pumpLibrary(
      tester,
      books: [bookEntry(title: 'Hero', progress: 0.5, lastReadAt: _t(2))],
    );

    await tester.tap(find.byType(ContinueReadingCard));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
  });

  testWidgets('import shows progress card and cancel', (tester) async {
    final h = await pumpLibrary(tester);

    await startImport(tester);
    expect(find.byKey(const Key('importing_book')), findsOneWidget);
    h.imports.current.add(const ImportUpdate.progress(done: 1, total: 3));
    await settleImport(tester);
    expect(find.text('Конвертация · 1 из 3'), findsOneWidget);
    expect(find.byType(ImportingBookCard), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel_import')));
    await tester.pump();
    expect(h.imports.cancelCalls, 1);
  });

  testWidgets('import success opens reader', (tester) async {
    final h = await pumpLibrary(tester);

    await startImport(tester);
    h.imports.current.add(ImportUpdate.converted(Uint8List.fromList([1])));
    await settleImport(tester);
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(h.books.added, hasLength(1));
  });

  testWidgets('delete during import keeps import card', (tester) async {
    final h = await pumpLibrary(
      tester,
      books: [bookEntry(id: 'a', title: 'Пример книги')],
    );

    await startImport(tester);
    await tester.longPress(find.byType(BookCard));
    await settleImport(tester);
    await tester.tap(find.byKey(const Key('book_action_delete')));
    await settleImport(tester);
    await tester.tap(find.byKey(const Key('delete_confirm')));
    await settleImport(tester);

    expect(h.books.deleted, ['a']);
    expect(find.byKey(const Key('importing_book')), findsOneWidget);
    expect(h.imports.cancelCalls, 0);
  });

  testWidgets('busy import shows snackbar', (tester) async {
    final h = await pumpLibrary(tester);

    await startImport(tester);
    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Дождитесь окончания добавления книги'), findsOneWidget);
    expect(h.imports.pickCalls, 1);
  });

  testWidgets('closing the picker changes nothing', (tester) async {
    await pumpLibrary(tester, picked: null);

    await tester.tap(find.byKey(const Key('add_book')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick_file')));
    await tester.pumpAndSettle();

    expect(find.byType(LibraryEmptyView), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('debug menu opens hyphen spike', (tester) async {
    await pumpLibrary(tester);

    await openHyphenSpike(tester);

    expect(find.byType(HyphenSpikeScreen), findsOneWidget);
  });

  testWidgets('book card is read once and progress has a label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLibrary(
      tester,
      books: [
        bookEntry(id: 'hero', progress: 0.1, lastReadAt: _t(9)),
        bookEntry(id: 'b', title: 'Дюна'),
      ],
    );

    final label = tester.getSemantics(find.byType(BookCard)).label;
    expect('Дюна'.allMatches(label), hasLength(1));
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.semanticsLabel, '10%');
    semantics.dispose();
  });
}
