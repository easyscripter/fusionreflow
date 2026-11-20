import 'dart:async';

import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/library_sort.dart';
import 'package:fusionreflow/domain/models/reading_status.dart';
import 'package:fusionreflow/ui/library/view_models/library_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_view_model.g.dart';

/// Без автоповтора: ошибка показывается сразу, «Повторить» — `invalidate`.
Duration? _noRetry(int retryCount, Object error) => null;

/// Книги библиотеки в выбранном порядке и книга для «Продолжить чтение».
@Riverpod(retry: _noRetry)
class LibraryViewModel extends _$LibraryViewModel {
  LibrarySort _sort = LibrarySort.recent;
  List<BookEntry> _books = const [];
  late StreamController<LibraryState> _out;

  @override
  Stream<LibraryState> build() {
    _sort = LibrarySort.recent;
    _books = const [];
    final out = _out = StreamController<LibraryState>();
    final sub = ref
        .watch(bookRepositoryProvider)
        .watchAll()
        .listen(
          (books) {
            _books = books;
            _emit();
          },
          onError: out.addError,
          onDone: out.close,
        );
    ref.onDispose(() {
      unawaited(sub.cancel());
      unawaited(out.close());
    });
    return out.stream;
  }

  /// Меняет порядок без нового запроса к репозиторию.
  void setSort(LibrarySort sort) {
    _sort = sort;
    _emit();
  }

  void _emit() {
    final continueReading = _continueReading(_books);
    final sorted = sortBooks(_books, _sort);
    _out.add(
      LibraryState(
        books: [
          for (final book in sorted)
            if (book.id != continueReading?.id) book,
        ],
        totalCount: _books.length,
        sort: _sort,
        continueReading: continueReading,
      ),
    );
  }

  static BookEntry? _continueReading(List<BookEntry> books) {
    BookEntry? best;
    for (final book in books) {
      final read = book.lastReadAt;
      if (read == null || book.readingStatus == ReadingStatus.finished) {
        continue;
      }
      final bestRead = best?.lastReadAt;
      if (bestRead == null || read.isAfter(bestRead)) best = book;
    }
    return best;
  }
}
