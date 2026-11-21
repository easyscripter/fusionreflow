import 'dart:async';

import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/repositories/book_exceptions.dart';
import 'package:fusionreflow/domain/models/reading_position.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/core/theme/reader_palette.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_state.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_view_model.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_page_turner.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_screen.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/reader_fixtures.dart';

const _id = 'b1';

FakeBookRepository _repo() =>
    FakeBookRepository([bookEntry(id: _id)])..opened[_id] = threeChapters();

Future<void> _open(
  WidgetTester tester,
  FakeBookRepository repo, {
  Size size = const Size(390, 844),
}) =>
    pumpApp(tester, books: repo, size: size, location: AppRoutes.readerOf(_id));

Finder _footerPage() => find.textContaining(RegExp(r'^\d+ из \d+$'));

String _pageLabel(WidgetTester tester) =>
    tester.widget<Text>(_footerPage()).data!;

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ReaderScreen)));

void main() {
  testWidgets('shows_loading_then_page', (tester) async {
    final repo = _repo()..openGate = Completer<void>();
    await pumpApp(
      tester,
      books: repo,
      location: AppRoutes.readerOf(_id),
      settle: false,
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Глава 1 из 3'), findsNothing);

    repo.openGate!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Первая'), findsOneWidget);
    expect(find.text('Глава 1 из 3'), findsOneWidget);
    expect(_pageLabel(tester), startsWith('1 из '));
    expect(find.text('0%'), findsOneWidget);
    expect(find.byType(ReaderPageTurner), findsOneWidget);
  });

  testWidgets('tap_right_and_left_turn_pages', (tester) async {
    final repo = _repo();
    await _open(tester, repo);
    final size = tester.view.physicalSize;

    await tester.tapAt(Offset(size.width * 0.9, 400));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('2 из '));
    expect(repo.saved, hasLength(1));

    await tester.tapAt(Offset(size.width * 0.5, 400));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('2 из '));

    await tester.tapAt(Offset(size.width * 0.1, 400));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('1 из '));
    expect(repo.saved, hasLength(2));

    // The first page of the book: a tap on the left does nothing.
    await tester.tapAt(Offset(size.width * 0.1, 400));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('1 из '));
    expect(repo.saved, hasLength(2));
  });

  testWidgets('swipe_turns_page', (tester) async {
    await _open(tester, _repo());

    await tester.fling(
      find.byType(ReaderPageTurner),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('2 из '));

    // A short drag springs back.
    await tester.drag(find.byType(ReaderPageTurner), const Offset(-40, 0));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('2 из '));

    // A swipe right goes back; a swipe right on the first page does not.
    await tester.fling(
      find.byType(ReaderPageTurner),
      const Offset(300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('1 из '));
    await tester.fling(
      find.byType(ReaderPageTurner),
      const Offset(300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), startsWith('1 из '));
  });

  testWidgets('drag past the half turns the page without a fling', (
    tester,
  ) async {
    await _open(tester, _repo());

    final gesture = await tester.startGesture(const Offset(300, 400));
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();
    expect(find.byType(ReaderPageTurner), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(_pageLabel(tester), startsWith('2 из '));
  });

  testWidgets('book_not_found_and_corrupt', (tester) async {
    await _open(tester, FakeBookRepository([bookEntry(id: _id)]));
    expect(find.text('Книга не найдена'), findsOneWidget);
    expect(find.text('Назад'), findsOneWidget);

    await tester.tap(find.text('Назад'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library_screen')), findsOneWidget);
  });

  testWidgets('corrupt book says it cannot be opened', (tester) async {
    final repo = _repo()..openError = const BookFormatException('bad');
    await _open(tester, repo);

    expect(find.text('Не удалось открыть книгу'), findsOneWidget);
    expect(find.text('Назад'), findsOneWidget);
  });

  testWidgets('hides_system_ui', (tester) async {
    final modes = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setEnabledSystemUIMode') {
          modes.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await _open(tester, _repo());
    expect(modes, ['SystemUiMode.immersiveSticky']);

    await tester.pumpWidget(const SizedBox());
    expect(modes, ['SystemUiMode.immersiveSticky', 'SystemUiMode.edgeToEdge']);
  });

  testWidgets('rotation_relayouts', (tester) async {
    final repo = _repo();
    await _open(tester, repo);
    final model = readerViewModelProvider(_id);
    expect(_container(tester).read(model).requireValue.viewport?.width, 390);
    final saved = repo.saved.length;

    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();

    final viewport = _container(tester).read(model).requireValue.viewport;
    expect(viewport?.width, 844);
    expect(viewport?.height, 390 - 64 - 66);
    expect(repo.saved, hasLength(saved));
  });

  testWidgets('save failure shows a snack bar', (tester) async {
    final repository = _repo()..saveError = Exception('disk');
    await _open(tester, repository);

    await tester.tapAt(const Offset(370, 400));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось сохранить место чтения'), findsOneWidget);
    expect(_pageLabel(tester), startsWith('2 из '));
  });

  testWidgets('dark theme gives the dark page palette', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _open(tester, _repo());

    final scaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(ReaderScreen),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffold.backgroundColor, ReaderPalette.dark.pageBackground);
  });

  testWidgets('a chapter without a title hides the chapter label', (
    tester,
  ) async {
    final untitled = FakeBookRepository([
      bookEntry(
        id: _id,
        position: const ReadingPosition(chapter: 2, offset: 0),
      ),
    ])..opened[_id] = threeChapters();
    await _open(tester, untitled);

    expect(find.textContaining('Глава '), findsNothing);
    expect(_footerPage(), findsOneWidget);
  });

  testWidgets('last page shows 100 percent', (tester) async {
    final repository = FakeBookRepository([
      bookEntry(
        id: _id,
        position: const ReadingPosition(chapter: 2, offset: 100000),
      ),
    ])..opened[_id] = threeChapters();
    await _open(tester, repository);

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Глава 3 из 3'), findsNothing);
  });

  testWidgets('rotation after tap paging keeps the first line of the page', (
    tester,
  ) async {
    await _open(tester, _repo());
    final model = readerViewModelProvider(_id);
    for (var i = 0; i < 3; i++) {
      await tester.tapAt(const Offset(370, 400));
      await tester.pumpAndSettle();
    }
    final before = _container(tester).read(model).requireValue;
    final start = before.currentPage!.start;
    expect(before.position.offset, start);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();

    final after = _container(tester).read(model).requireValue;
    expect(after.currentPage!.contains(start), isTrue);
    expect(after.position.offset, after.currentPage!.start);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    final back = _container(tester).read(model).requireValue;
    expect(back.currentPage!.contains(after.currentPage!.start), isTrue);
  });

  testWidgets('header stays below a display cutout', (tester) async {
    tester.view
      ..padding = const FakeViewPadding(top: 90)
      ..viewPadding = const FakeViewPadding(top: 90);
    addTearDown(tester.view.reset);
    await _open(tester, _repo());

    final title = tester.getTopLeft(find.text('Первая'));
    expect(title.dy, greaterThanOrEqualTo(90));
    final viewport = _container(tester)
        .read(readerViewModelProvider(_id))
        .requireValue
        .viewport;
    // 98 (inset + 8) + 34 for the title line, instead of the plain 64.
    expect(viewport?.height, 844 - 132 - 66);
  });

  testWidgets('side cutout in landscape does not push the header down', (
    tester,
  ) async {
    tester.view.displayFeatures = const [
      DisplayFeature(
        bounds: Rect.fromLTWH(0, 150, 40, 40),
        type: DisplayFeatureType.cutout,
        state: DisplayFeatureState.unknown,
      ),
    ];
    addTearDown(tester.view.reset);
    await _open(tester, _repo(), size: const Size(844, 390));

    expect(tester.getTopLeft(find.text('Первая')).dy, lessThan(40));
  });

  testWidgets('page number is centered whatever the side labels are', (
    tester,
  ) async {
    await _open(tester, _repo());

    expect(tester.getCenter(_footerPage()).dx, closeTo(195, 0.5));
  });
}
