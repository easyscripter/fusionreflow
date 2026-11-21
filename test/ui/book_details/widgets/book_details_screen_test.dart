import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/library/widgets/book_card.dart';
import 'package:intl/intl.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';
import '../../../helpers/pump_app.dart';

const _short = 'Роман о визите дьявола в Москву.';
final String _long = List.filled(60, 'Длинное описание книги').join(' ');
final DateTime _added = DateTime.utc(2026, 11, 9);

Future<FakeBookRepository> _open(
  WidgetTester tester,
  List<BookEntry> books, {
  String id = 'x',
  Size size = const Size(390, 844),
}) async {
  final repo = FakeBookRepository(books);
  await pumpApp(
    tester,
    books: repo,
    size: size,
    location: AppRoutes.bookDetailsOf(id),
  );
  return repo;
}

void main() {
  final full = bookEntry(
    id: 'x',
    title: 'Пример книги',
    authors: ['А. Автор'],
    progress: 0.34,
    addedAt: _added,
    language: 'ru',
    description: _short,
    sourceSize: 1887437,
  );

  testWidgets('shows full card', (tester) async {
    await _open(tester, [full]);

    expect(find.text('Пример книги'), findsWidgets);
    expect(find.text('А. Автор'), findsWidgets);
    expect(find.text('EPUB · 1,8 МБ · Русский'), findsOneWidget);
    expect(find.text('Прочитано 34%'), findsOneWidget);
    expect(find.text('Продолжить чтение'), findsOneWidget);
    expect(find.text('Размер файла'), findsOneWidget);
    expect(find.text('Русский'), findsWidgets);
    expect(find.text(_short), findsOneWidget);
    expect(find.text(DateFormat.yMMMd('ru').format(_added)), findsOneWidget);
  });

  testWidgets('shows empty card', (tester) async {
    await _open(tester, [
      bookEntry(id: 'x', title: 'Конспект', authors: [], addedAt: _added),
    ]);

    expect(find.text('Автор не указан'), findsOneWidget);
    expect(find.text('В файле нет описания.'), findsOneWidget);
    expect(find.byKey(const Key('book_read_more')), findsNothing);
    expect(find.text('Не определён'), findsOneWidget);
    expect(find.text('Не начата'), findsOneWidget);
    expect(find.text('Начать чтение'), findsOneWidget);
  });

  testWidgets('hides size when unknown', (tester) async {
    await _open(tester, [full.copyWith(sourceSize: null)]);

    expect(find.text('Размер файла'), findsNothing);
    expect(find.text('EPUB · Русский'), findsOneWidget);
  });

  testWidgets('finished book', (tester) async {
    await _open(tester, [full.copyWith(progress: 1)]);

    expect(find.text('Прочитана'), findsOneWidget);
    expect(find.text('Продолжить чтение'), findsOneWidget);
  });

  testWidgets('no read more for a short description', (tester) async {
    await _open(tester, [full]);

    expect(find.byKey(const Key('book_read_more')), findsNothing);
  });

  testWidgets('read more shows for a long description', (tester) async {
    await _open(tester, [full.copyWith(description: _long)]);

    expect(find.byKey(const Key('book_read_more')), findsOneWidget);
  });

  testWidgets('read more opens description sheet', (tester) async {
    await _open(tester, [full.copyWith(description: '$_long\n\nВторой.')]);

    await tester.tap(find.byKey(const Key('book_read_more')));
    await tester.pumpAndSettle();

    final sheet = find.byKey(const Key('book_description'));
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Второй.')),
      findsOneWidget,
    );
    expect(
      find.text('Текст взят из метаданных файла и показан как есть.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('book_description_close')));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
  });

  testWidgets('description sheet starts 150 dp from the top', (tester) async {
    await _open(tester, [full.copyWith(description: '$_long\n\nВторой.')]);

    await tester.tap(find.byKey(const Key('book_read_more')));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(BottomSheet)).dy, 150);
  });

  testWidgets('huge description scrolls and keeps the note', (tester) async {
    final huge = List.generate(40, (i) => 'Абзац $i. $_long').join('\n\n');
    await _open(tester, [full.copyWith(description: huge)]);
    await tester.tap(find.byKey(const Key('book_read_more')));
    await tester.pumpAndSettle();
    final first = find.descendant(
      of: find.byKey(const Key('book_description')),
      matching: find.textContaining('Абзац 0.'),
    );
    final note = find.text(
      'Текст взят из метаданных файла и показан как есть.',
    );
    final noteTop = tester.getTopLeft(note).dy;
    final firstTop = tester.getTopLeft(first).dy;

    await tester.drag(
      find.descendant(
        of: find.byKey(const Key('book_description')),
        matching: find.byType(SingleChildScrollView),
      ),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(first).dy, lessThan(firstTop));
    expect(tester.getTopLeft(note).dy, noteTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('read button opens reader', (tester) async {
    final repo = FakeBookRepository([full]);
    await pumpApp(tester, books: repo);
    await tester.longPress(find.byType(BookCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('book_action_details')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('book_read')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reader_placeholder')), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('book_details')), findsOneWidget);
  });

  testWidgets('deleted book shows not found', (tester) async {
    final repo = await _open(tester, [full]);

    repo.emit([]);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('book_not_found')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown id shows not found', (tester) async {
    await _open(tester, [full], id: 'nope');

    expect(find.byKey(const Key('book_not_found')), findsOneWidget);
  });

  testWidgets('tablet centers content', (tester) async {
    await _open(tester, [full], size: const Size(820, 1180));

    final width = tester.getSize(find.byType(ListView)).width;
    final center = tester.getCenter(find.byType(ListView)).dx;
    expect(width, lessThanOrEqualTo(600));
    expect(center, 410);
  });

  testWidgets('text scale 2 does not overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repo = FakeBookRepository([
      full.copyWith(description: '$_long\n\nВторой.'),
    ]);
    await pumpApp(tester, books: repo);

    await tester.longPress(find.byType(BookCard));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('book_action_delete')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('delete_cancel')));
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(BookCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('book_action_details')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // ListView is lazy: the details table is built only once scrolled to.
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('Детали'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('book_read_more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('book_description')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
