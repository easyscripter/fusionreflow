import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/library_sort.dart';

part 'library_state.freezed.dart';

/// Что показывает экран «Библиотека».
@freezed
abstract class LibraryState with _$LibraryState {
  const factory({
    /// Сетка: все книги (и [continueReading] тоже) в порядке [sort].
    required List<BookEntry> books,

    /// Все живые книги (счётчик «8 книг»).
    required int totalCount,
    required LibrarySort sort,

    /// Книга с наибольшим lastReadAt, кроме прочитанных.
    BookEntry? continueReading,
  }) = _LibraryState;
}
