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

  /// Bytes and formats passed to [add].
  final List<(Uint8List, BookFormat)> added = [];

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

  @override
  Stream<List<BookEntry>> watchAll() async* {
    watchCalls++;
    final error = watchError;
    if (error != null) throw error;
    yield _books;
    yield* _changes.stream;
  }

  @override
  Future<BookEntry> add(Uint8List bytes, BookFormat format) async {
    added.add((bytes, format));
    final error = addError;
    if (error != null) throw error;
    final book = addResult ?? bookEntry(id: 'new', title: 'New book');
    if (!_books.any((b) => b.id == book.id)) emit([book, ..._books]);
    return book;
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
  Future<void> delete(String id) => throw UnimplementedError();
}
