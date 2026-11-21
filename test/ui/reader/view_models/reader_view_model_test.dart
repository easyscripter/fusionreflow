import 'dart:ui' show Size;

import 'package:flow_render/flow_render.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/repositories/book_exceptions.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/domain/models/reading_position.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_state.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_view_model.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';
import '../../../helpers/reader_fixtures.dart';

const _id = 'b1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBookRepository repo;
  late ProviderContainer container;

  ReaderViewModel vm() => container.read(readerViewModelProvider(_id).notifier);
  ReaderState state() =>
      container.read(readerViewModelProvider(_id)).requireValue;

  Future<void> start({
    ReadingPosition position = ReadingPosition.start,
    FlowBook? book,
    Size? size = portrait,
  }) async {
    repo = FakeBookRepository([bookEntry(id: _id, position: position)])
      ..opened[_id] = book ?? threeChapters();
    container = ProviderContainer(
      overrides: [bookRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(readerViewModelProvider(_id), (_, _) {});
    await container.read(readerViewModelProvider(_id).future);
    if (size != null) await vm().setViewport(size, testFlowStyle);
  }

  test('loads the book before the viewport is known', () async {
    await start(size: null);

    expect(state().book.title, 'Книга');
    expect(state().currentPage, isNull);
    expect(state().viewport, isNull);
    expect(repo.openCalls, [_id]);
  });

  test('opens_at_saved_position', () async {
    await start(position: const ReadingPosition(chapter: 1, offset: 2000));

    final s = state();
    expect(s.chapterIndex, 1);
    expect(s.currentPage?.contains(2000), isTrue);
    expect(s.chapterTitle, 'Вторая');
    expect(s.pages.keys.toSet(), {0, 1, 2});
  });

  test('clamps_position_outside_book', () async {
    await start(
      position: const ReadingPosition(chapter: 99, offset: 1000000000),
    );

    final s = state();
    expect(s.chapterIndex, 2);
    expect(s.currentPage?.last, isTrue);
    expect(s.pageInChapter, s.pagesInChapter);
    expect(s.pages.keys.toSet(), {1, 2});
    expect(s.percent, 100);
  });

  test('negative position is clamped to the start', () async {
    await start(position: const ReadingPosition(chapter: -3, offset: -5));

    expect(state().chapterIndex, 0);
    expect(state().pageInChapter, 1);
    expect(state().percent, 0);
  });

  test('missing book fails with not found', () async {
    repo = FakeBookRepository([bookEntry(id: _id)]);
    container = ProviderContainer(
      overrides: [bookRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(readerViewModelProvider(_id), (_, _) {});

    await expectLater(
      container.read(readerViewModelProvider(_id).future),
      throwsA(isA<BookNotFoundException>()),
    );
  });

  test('book removed from the library fails with not found', () async {
    repo = FakeBookRepository()..opened[_id] = threeChapters();
    container = ProviderContainer(
      overrides: [bookRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(readerViewModelProvider(_id), (_, _) {});

    await expectLater(
      container.read(readerViewModelProvider(_id).future),
      throwsA(isA<BookNotFoundException>()),
    );
  });

  test('next_page_saves_position', () async {
    await start();
    final first = state().currentPage!;

    await vm().showPage(1);

    final s = state();
    expect(s.pageInChapter, 2);
    final page = s.currentPage!;
    expect(page.start, first.end);
    final total = threeChapters().sections.fold<int>(0, (a, b) => a + b.length);
    expect(repo.saved, hasLength(1));
    final (id, position, progress) = repo.saved.single;
    expect(id, _id);
    expect(position, ReadingPosition(chapter: 0, offset: page.start));
    expect(progress, closeTo(page.start / total, 1e-9));
    expect(s.percent, (progress * 100).floor());
  });

  test('crosses_chapter_boundary', () async {
    await start();
    final pages0 = state().pages[0]!;
    for (var i = 1; i < pages0.length; i++) {
      await vm().showPage(1);
    }
    expect(state().chapterIndex, 0);
    expect(state().currentPage, pages0.last);

    await vm().showPage(1);

    expect(state().chapterIndex, 1);
    expect(state().pageInChapter, 1);
    expect(state().chapterTitle, 'Вторая');
    expect(repo.saved.last.$2, const ReadingPosition(chapter: 1, offset: 0));

    await vm().showPage(-1);

    expect(state().chapterIndex, 0);
    expect(state().currentPage, pages0.last);
    expect(state().pages.keys.toSet(), {0, 1});
  });

  test('stops_at_book_edges', () async {
    await start();

    await vm().showPage(-1);
    expect(state().pageInChapter, 1);
    expect(repo.saved, isEmpty);

    await start(position: const ReadingPosition(chapter: 2, offset: 1000000));
    final last = state().currentPage;
    await vm().showPage(1);
    expect(state().currentPage, last);
    expect(repo.saved, isEmpty);
  });

  test('neighbour pages follow the current one', () async {
    await start();
    expect(state().previousPage, isNull);
    expect(state().nextPage, state().currentPages![1]);

    await vm().showPage(1);
    expect(state().previousPage, state().currentPages![0]);

    final s = state();
    expect(s.pagesInChapter, s.currentPages!.length);
    // Last page of chapter 0: next is the first page of chapter 1.
    for (var i = 2; i < s.pagesInChapter; i++) {
      await vm().showPage(1);
    }
    expect(state().nextPage, state().pages[1]!.first);
  });

  test('resize_keeps_fragment', () async {
    await start(position: const ReadingPosition(chapter: 1, offset: 2500));

    await vm().setViewport(landscape, testFlowStyle);

    expect(state().viewport, landscape);
    expect(state().currentPage?.contains(2500), isTrue);
    final landscapeStart = state().currentPage!.start;
    await vm().setViewport(portrait, testFlowStyle);
    expect(state().currentPage?.contains(landscapeStart), isTrue);
    expect(repo.saved, isEmpty);
  });

  test('stale_relayout_is_dropped', () async {
    await start(size: null);

    final first = vm().setViewport(portrait, testFlowStyle);
    final second = vm().setViewport(landscape, testFlowStyle);
    await Future.wait([first, second]);

    expect(state().viewport, landscape);
    final pages = state().currentPages!;
    expect(pages.first.items.first.rect.right, lessThanOrEqualTo(500.01));
    expect(pages.length, lessThan(40));
  });

  test('showPage before the viewport is known does nothing', () async {
    await start(size: null);

    await vm().showPage(1);

    expect(repo.saved, isEmpty);
    expect(state().position, ReadingPosition.start);
  });

  test('save_failure_reports_error', () async {
    await start();
    repo.saveError = Exception('disk full');

    await vm().showPage(1);

    expect(state().saveFailures, 1);
    expect(state().pageInChapter, 2);

    repo.saveError = const BookNotFoundException(_id);
    await vm().showPage(1);

    expect(state().saveFailures, 1);
    expect(state().pageInChapter, 3);
  });

  test('empty book has one empty page', () async {
    await start(book: const FlowBook('Пусто', [FlowSection([])]));

    expect(state().currentPage?.items, isEmpty);
    expect(state().pagesInChapter, 1);
    expect(state().percent, 100);
    await vm().showPage(1);
    expect(repo.saved, isEmpty);
  });

  test('a late relayout does not resurrect a disposed model', () async {
    await start(size: null);
    final pending = vm().setViewport(portrait, testFlowStyle);
    container.dispose();

    await pending;
  });

  test('rotation_after_paging_keeps_first_char_of_page', () async {
    await start(position: const ReadingPosition(chapter: 1, offset: 0));
    for (var i = 0; i < 3; i++) {
      await vm().showPage(1);
    }
    final shownStart = state().currentPage!.start;
    expect(state().position.offset, shownStart);

    await vm().setViewport(landscape, testFlowStyle);

    // The page on screen holds the first character of the old page, and
    // the position is now the start of that page.
    expect(state().currentPage!.contains(shownStart), isTrue);
    expect(state().position.offset, state().currentPage!.start);
    final landscapeStart = state().currentPage!.start;

    await vm().setViewport(portrait, testFlowStyle);

    expect(state().currentPage!.contains(landscapeStart), isTrue);
    expect(state().position.offset, state().currentPage!.start);
  });

  test('progress is weighted by the text of the chapters', () {
    // Chapter 4 of 5 is long, but the book is dominated by the last one.
    const state = ReaderState(
      book: FlowBook('', [FlowSection([])]),
      position: ReadingPosition(chapter: 3, offset: 30000),
      chapterLengths: [759, 21, 1823, 60013, 5066792],
    );

    expect(state.progress, closeTo((2603 + 30000) / 5129408, 1e-12));
    expect(state.progress * 100, lessThan(1));
  });
}
