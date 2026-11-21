import 'dart:async';
import 'dart:typed_data';

import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/reading_position.dart';

import 'book_entry.dart';

/// In-memory [BookRepository]: a test sets [books] and watches the stream.
class FakeBookRepository implements BookRepository {
  /// Creates the fake with [books] already in the library.
  new([this._books = const []]);

  List<BookEntry> _books;
  final StreamController<List<BookEntry>> _changes =
      StreamController<List<BookEntry>>.broadcast();

  /// Number of [watchAll] calls.
  int watchCalls = 0;

  /// Thrown by [watchAll] when set.
  Exception? watchError;

  /// Bytes, formats and sizes passed to [add].
  final List<(Uint8List, BookFormat, int?)> added = [];

  /// Ids passed to [delete].
  final List<String> deleted = [];

  /// Thrown by [delete] when set.
  Exception? deleteError;

  /// What [add] returns; when null a new book `new` is created.
  BookEntry? addResult;

  /// Thrown by [add] when set.
  Exception? addError;

  /// Current books.
  List<BookEntry> get books => _books;

  /// Replaces the library and notifies watchers.
  void emit(List<BookEntry> books) {
    _books = books;
    _changes.add(books);
  }

  /// Fails the [watchAll] stream of every watcher.
  void emitError(Object error) => _changes.addError(error);

  @override
  Stream<List<BookEntry>> watchAll() async* {
    watchCalls++;
    final error = watchError;
    if (error != null) throw error;
    yield _books;
    yield* _changes.stream;
  }

  @override
  Future<BookEntry> add(
    Uint8List bytes,
    BookFormat format, {
    int? sourceSize,
  }) async {
    added.add((bytes, format, sourceSize));
    final error = addError;
    if (error != null) throw error;
    final book = addResult ?? bookEntry(id: 'new', title: 'New book');
    if (!_books.any((b) => b.id == book.id)) emit([book, ..._books]);
    return book;
  }

  @override
  Stream<BookEntry?> watch(String id) async* {
    BookEntry? find() => _books.where((b) => b.id == id).firstOrNull;
    yield find();
    yield* _changes.stream.map((_) => find());
  }

  @override
  Future<Uint8List> load(String id) => throw UnimplementedError();

  @override
  Future<void> savePosition(
    String id,
    ReadingPosition position,
    double progress,
  ) => throw UnimplementedError();

  @override
  Future<void> delete(String id) async {
    deleted.add(id);
    final error = deleteError;
    if (error != null) throw error;
    emit([
      for (final b in _books)
        if (b.id != id) b,
    ]);
  }
}
