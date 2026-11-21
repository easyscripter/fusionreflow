import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_details_view_model.g.dart';

/// Book [bookId] for the card; null when it is missing or deleted.
@riverpod
Stream<BookEntry?> bookDetailsViewModel(Ref ref, String bookId) =>
    ref.watch(bookRepositoryProvider).watch(bookId);
