import 'dart:ui' show Size;

import 'package:flow_render/flow_render.dart';
import 'package:fusionreflow/config/flow_paginator_provider.dart';
import 'package:fusionreflow/config/no_retry.dart';
import 'package:fusionreflow/data/repositories/book_exceptions.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/domain/models/reading_position.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_view_model.g.dart';

/// Reading of book [bookId]: opens it at the saved position, lays out the
/// current chapter and its neighbours, turns pages and saves the place.
@Riverpod(retry: noRetry)
class ReaderViewModel extends _$ReaderViewModel {
  /// Bumped by every new layout request and on dispose; an older request
  /// that finishes later is dropped.
  int _generation = 0;
  final Set<int> _inFlight = {};

  @override
  Future<ReaderState> build(String bookId) async {
    ref.onDispose(() => _generation++);
    final repo = ref.watch(bookRepositoryProvider);
    final book = await repo.open(bookId);
    final entry = await repo.watch(bookId).first;
    if (entry == null) throw BookNotFoundException(bookId);
    final lengths = [for (final s in book.sections) s.length];
    final saved = entry.position;
    final chapter = saved.chapter.clamp(0, book.sections.length - 1);
    return ReaderState(
      book: book,
      position: ReadingPosition(
        chapter: chapter,
        offset: saved.offset.clamp(0, lengths[chapter]),
      ),
      chapterLengths: lengths,
    );
  }

  /// Lays the book out for a page of [size]: the first call and every turn
  /// of the phone or change of the window. The page that contains the
  /// position stays open; a request that is not the last one is dropped.
  Future<void> setViewport(Size size, FlowStyle style) async {
    final current = state.value;
    if (current == null) return;
    final token = ++_generation;
    _inFlight.clear();
    state = AsyncData(current.copyWith(viewport: size, style: style));
    try {
      await _relayout(token, size, style);
    } on Object catch (error, stack) {
      // The call is not awaited by the screen: show the error on it.
      if (_current(token)) state = AsyncError(error, stack);
    }
  }

  Future<void> _relayout(int token, Size size, FlowStyle style) async {
    while (true) {
      final chapter = state.requireValue.chapterIndex;
      final laidOut = await _layout(chapter, size, style);
      if (!_current(token)) return;
      final latest = state.requireValue;
      if (latest.chapterIndex != chapter) continue; // the user turned a page
      // Only the page index follows the new layout. The position stays the
      // same: replacing it with the start of the new page would walk the
      // book back with every turn of the phone.
      state = AsyncData(
        latest.copyWith(
          pages: {chapter: laidOut},
          pageIndex: pageIndexOf(laidOut, latest.position.offset),
        ),
      );
      break;
    }
    await _layoutNeighbours(token);
  }

  /// Turns the page by [delta] (only the sign counts); at the edges of the
  /// book nothing happens. Saves the place after the page is shown.
  Future<void> showPage(int delta) async {
    final current = state.value;
    final pages = current?.currentPages;
    if (current == null || pages == null || delta == 0) return;
    var chapter = current.chapterIndex;
    var index = current.pageIndex + delta.sign;
    if (index >= pages.length) {
      chapter++;
      index = 0;
    } else if (index < 0) {
      chapter--;
      index = (current.pages[chapter]?.length ?? 0) - 1;
    }
    final target = current.pages[chapter];
    if (target == null || index < 0) return; // edge of the book or not ready
    final position = ReadingPosition(
      chapter: chapter,
      offset: target[index].start,
    );
    final shown = current.copyWith(
      position: position,
      pageIndex: index,
      pages: {
        for (final e in current.pages.entries)
          if ((e.key - chapter).abs() <= 1) e.key: e.value,
      },
    );
    state = AsyncData(shown);
    await _save(shown);
    final token = _generation;
    try {
      await _layoutNeighbours(token);
    } on Object catch (error, stack) {
      if (_current(token)) state = AsyncError(error, stack);
    }
  }

  Future<void> _save(ReaderState shown) async {
    try {
      await ref
          .read(bookRepositoryProvider)
          .savePosition(bookId, shown.position, shown.progress);
    } on BookNotFoundException {
      // The book was deleted while it was open: nothing to save.
    } on Object {
      if (!ref.mounted) return;
      final latest = state.requireValue;
      state = AsyncData(latest.copyWith(saveFailures: latest.saveFailures + 1));
    }
  }

  bool _current(int token) => ref.mounted && token == _generation;

  Future<List<FlowPage>> _layout(int chapter, Size size, FlowStyle style) => ref
      .read(flowPaginatorProvider)
      .paginate(state.requireValue.book.sections[chapter], size, style);

  /// Lays out the chapters next to the current one that are not ready.
  Future<void> _layoutNeighbours(int token) async {
    for (final step in const [1, -1]) {
      if (!_current(token)) return;
      final s = state.requireValue;
      final chapter = s.chapterIndex + step;
      final size = s.viewport;
      final style = s.style;
      if (size == null ||
          style == null ||
          chapter < 0 ||
          chapter >= s.chapterCount ||
          s.pages.containsKey(chapter) ||
          !_inFlight.add(chapter)) {
        continue;
      }
      final List<FlowPage> laidOut;
      try {
        laidOut = await _layout(chapter, size, style);
      } finally {
        _inFlight.remove(chapter);
      }
      if (!_current(token)) return;
      final latest = state.requireValue;
      if ((latest.chapterIndex - chapter).abs() > 1) continue;
      state = AsyncData(
        latest.copyWith(pages: {...latest.pages, chapter: laidOut}),
      );
    }
  }
}
