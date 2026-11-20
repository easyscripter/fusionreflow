import 'package:fusionreflow/domain/models/book_entry.dart';

/// Порядок книг в библиотеке.
enum LibrarySort { recent, title, author }

/// Книги в порядке [sort]; исходный список не меняется.
List<BookEntry> sortBooks(Iterable<BookEntry> books, LibrarySort sort) {
  final compare = switch (sort) {
    LibrarySort.recent => _byRecent,
    LibrarySort.title => _byTitle,
    LibrarySort.author => _byAuthor,
  };
  return [...books]..sort((a, b) {
    final c = compare(a, b);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
}

DateTime _lastTouched(BookEntry b) => b.lastReadAt ?? b.addedAt;

int _byRecent(BookEntry a, BookEntry b) =>
    _lastTouched(b).compareTo(_lastTouched(a));

/// Без регистра, `ё` = `е` (по кодам «ё» встала бы после «я»).
String _key(String text) => text.toLowerCase().replaceAll('ё', 'е');

int _byTitle(BookEntry a, BookEntry b) =>
    _key(a.title).compareTo(_key(b.title));

int _byAuthor(BookEntry a, BookEntry b) {
  if (a.authors.isEmpty != b.authors.isEmpty) return a.authors.isEmpty ? 1 : -1;
  if (a.authors.isEmpty) return _byTitle(a, b);
  final c = _key(a.authors.first).compareTo(_key(b.authors.first));
  return c != 0 ? c : _byTitle(a, b);
}
