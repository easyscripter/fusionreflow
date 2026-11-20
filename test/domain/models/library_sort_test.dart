import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/library_sort.dart';

import '../../helpers/book_entry.dart';

DateTime _t(int n) => DateTime.utc(2026, 1, n);

List<String> _ids(Iterable<dynamic> books) =>
    books.map((b) => (b as dynamic).id as String).toList();

List<String> _titles(LibrarySort sort, List<String> titles) => sortBooks([
  for (final (i, t) in titles.indexed) bookEntry(id: '$i', title: t),
], sort).map((b) => b.title).toList();

void main() {
  test('recent uses lastReadAt then addedAt', () {
    final books = [
      bookEntry(id: 'C', addedAt: _t(2), lastReadAt: _t(3)),
      bookEntry(id: 'B', addedAt: _t(4)),
      bookEntry(id: 'A', addedAt: _t(1), lastReadAt: _t(5)),
    ];
    expect(_ids(sortBooks(books, LibrarySort.recent)), ['A', 'B', 'C']);
  });

  test('title ignores case and treats ё as е', () {
    expect(_titles(LibrarySort.title, ['ящик', 'Ёлка', 'еж', 'Абв']), [
      'Абв',
      'еж',
      'Ёлка',
      'ящик',
    ]);
  });

  test('latin before cyrillic', () {
    expect(_titles(LibrarySort.title, ['Ящик', 'Apple']), ['Apple', 'Ящик']);
  });

  test('author puts books without authors last', () {
    final books = [
      bookEntry(id: 'none', authors: const []),
      bookEntry(id: 'boris', authors: const ['Борис']),
      bookEntry(id: 'anna', authors: const ['Анна']),
    ];
    expect(_ids(sortBooks(books, LibrarySort.author)), [
      'anna',
      'boris',
      'none',
    ]);
  });

  test('author ties break by title', () {
    final books = [
      bookEntry(id: '1', title: 'Б'),
      bookEntry(id: '2', title: 'А'),
    ];
    expect(_ids(sortBooks(books, LibrarySort.author)), ['2', '1']);
  });

  test('equal keys are ordered by id', () {
    final books = [bookEntry(id: 'b'), bookEntry(id: 'a')];
    for (final sort in LibrarySort.values) {
      expect(_ids(sortBooks(books, sort)), ['a', 'b']);
    }
  });

  test('does not mutate input', () {
    final books = [bookEntry(id: 'b'), bookEntry(id: 'a')];
    sortBooks(books, LibrarySort.title);
    expect(_ids(books), ['b', 'a']);
  });
}
