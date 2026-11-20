import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_placeholder_view_model.g.dart';

/// Книга [bookId] из библиотеки; null, если её нет (или удалена).
@riverpod
Stream<BookEntry?> readerPlaceholderViewModel(Ref ref, String bookId) => ref
    .watch(bookRepositoryProvider)
    .watchAll()
    .map((books) => books.where((b) => b.id == bookId).firstOrNull);
