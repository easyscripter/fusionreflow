import 'dart:ui' show Size;

import 'package:flow_render/flow_render.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fusionreflow/domain/models/reading_position.dart';

part 'reader_state.freezed.dart';

/// What the reader screen shows: the book, the position and the laid out
/// pages of the current chapter and its neighbours.
@freezed
abstract class ReaderState with _$ReaderState {
  const factory({
    required FlowBook book,

    /// Chapter and the offset of the first character of the current page.
    required ReadingPosition position,

    /// Length of every chapter (sum of its blocks), for the progress.
    required List<int> chapterLengths,

    /// Laid out chapters (current ± 1) by chapter index.
    @Default({}) Map<int, List<FlowPage>> pages,

    /// Current page in the current chapter.
    @Default(0) int pageIndex,

    /// Size the pages were laid out for; null until the screen reports it.
    Size? viewport,
    FlowStyle? style,

    /// How many times saving the position failed (the screen shows a message
    /// when it grows).
    @Default(0) int saveFailures,
  }) = _ReaderState;
}

/// What the screen shows, derived from [ReaderState].
extension ReaderStateView on ReaderState {
  int get chapterIndex => position.chapter;

  int get chapterCount => book.sections.length;

  String? get chapterTitle => book.sections[chapterIndex].title;

  List<FlowPage>? get currentPages => pages[chapterIndex];

  FlowPage? get currentPage => currentPages?[pageIndex];

  /// The page before the current one, across the chapter edge; null on the
  /// first page of the book or when it is not laid out yet.
  FlowPage? get previousPage {
    if (pageIndex > 0) return currentPages?[pageIndex - 1];
    return pages[chapterIndex - 1]?.last;
  }

  /// The page after the current one, across the chapter edge.
  FlowPage? get nextPage {
    final current = currentPages;
    if (current != null && pageIndex + 1 < current.length) {
      return current[pageIndex + 1];
    }
    return pages[chapterIndex + 1]?.first;
  }

  /// Number of the current page in the chapter, from 1.
  int get pageInChapter => pageIndex + 1;

  int get pagesInChapter => currentPages?.length ?? 1;

  bool get isLastPageOfBook =>
      chapterIndex == chapterCount - 1 && pageIndex + 1 == pagesInChapter;

  /// Share of the book before the first character of the current page.
  double get progress {
    final total = chapterLengths.fold<int>(0, (a, b) => a + b);
    if (total == 0) return 0;
    final before = chapterLengths
        .take(chapterIndex)
        .fold<int>(0, (a, b) => a + b);
    return ((before + position.offset) / total).clamp(0, 1).toDouble();
  }

  /// Percent for the footer: like the library's, but 100 on the last page.
  int get percent => isLastPageOfBook ? 100 : (progress * 100).floor();
}
