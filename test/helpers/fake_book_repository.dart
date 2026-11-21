import 'dart:async';
import 'dart:typed_data';

import 'package:flow_render/flow_render.dart';
import 'package:fusionreflow/data/repositories/book_exceptions.dart';
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

  /// Books [open] returns by id; an id that is not here is not found.
  final Map<String, FlowBook> opened = {};

  /// Thrown by [open] when set (before the lookup).
  Object? openError;

  /// Ids passed to [open].
  final List<String> openCalls = [];

  /// Completes [open] when set; lets a test keep the book loading.
  Completer<void>? openGate;

  @override
  Future<FlowBook> open(String id) async {
    openCalls.add(id);
    await openGate?.future;
    final error = openError;
    // ignore: only_throw_errors (tests throw Errors and Exceptions alike)
    if (error != null) throw error;
    return opened[id] ?? (throw BookNotFoundException(id));
  }

  @override
  Future<Uint8List> load(String id) => throw UnimplementedError();

  /// `(id, position, progress)` of every [savePosition] call.
  final List<(String, ReadingPosition, double)> saved = [];

  /// Thrown by [savePosition] when set.
  Object? saveError;

  @override
  Future<void> savePosition(
    String id,
    ReadingPosition position,
    double progress,
  ) async {
    saved.add((id, position, progress));
    final error = saveError;
    // ignore: only_throw_errors (tests throw Errors and Exceptions alike)
    if (error != null) throw error;
  }

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
