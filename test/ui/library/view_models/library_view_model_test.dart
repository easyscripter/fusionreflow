import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/domain/models/library_sort.dart';
import 'package:fusionreflow/ui/library/view_models/library_state.dart';
import 'package:fusionreflow/ui/library/view_models/library_view_model.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';

DateTime _t(int n) => DateTime.utc(2026, 1, n);

void main() {
  late FakeBookRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = FakeBookRepository();
    container = ProviderContainer(
      overrides: [bookRepositoryProvider.overrideWithValue(repo)],
    )..listen(libraryViewModelProvider, (_, _) {});
    addTearDown(container.dispose);
    await pumpEventQueue(); // let the fake's stream get subscribed
  });

  Future<LibraryState> state() async {
    await pumpEventQueue();
    return container.read(libraryViewModelProvider).requireValue;
  }

  test('emits sorted books with recent by default', () async {
    repo.emit([
      bookEntry(id: 'a', addedAt: _t(1)),
      bookEntry(id: 'b', addedAt: _t(3)),
      bookEntry(id: 'c', addedAt: _t(2)),
    ]);
    final s = await state();
    expect(s.sort, LibrarySort.recent);
    expect(s.books.map((b) => b.id), ['b', 'c', 'a']);
    expect(s.totalCount, 3);
  });

  test('continue reading is latest read unfinished', () async {
    repo.emit([
      bookEntry(id: 'done', progress: 1, lastReadAt: _t(5)),
      bookEntry(id: 'hero', progress: 0.4, lastReadAt: _t(3)),
    ]);
    final s = await state();
    expect(s.continueReading?.id, 'hero');
    expect(s.books.map((b) => b.id), ['done']);
    expect(s.totalCount, 2);
  });

  test('latest of several unfinished books wins', () async {
    repo.emit([
      bookEntry(id: 'old', progress: 0.1, lastReadAt: _t(2)),
      bookEntry(id: 'new', progress: 0.1, lastReadAt: _t(4)),
    ]);
    expect((await state()).continueReading?.id, 'new');
  });

  test('no continue reading when nothing read', () async {
    repo.emit([bookEntry(id: 'a'), bookEntry(id: 'b')]);
    final s = await state();
    expect(s.continueReading, isNull);
    expect(s.books, hasLength(2));
  });

  test('setSort reorders without new watch', () async {
    repo.emit([bookEntry(id: 'a', title: 'Б'), bookEntry(id: 'b', title: 'А')]);
    await state();
    container
        .read(libraryViewModelProvider.notifier)
        .setSort(LibrarySort.title);
    final s = await state();
    expect(s.books.map((b) => b.title), ['А', 'Б']);
    expect(repo.watchCalls, 1);
  });

  test('stream update keeps chosen sort', () async {
    await state();
    container
        .read(libraryViewModelProvider.notifier)
        .setSort(LibrarySort.author);
    repo.emit([
      bookEntry(id: 'a', authors: const ['Борис']),
      bookEntry(id: 'b', authors: const ['Анна']),
    ]);
    final s = await state();
    expect(s.sort, LibrarySort.author);
    expect(s.books.map((b) => b.id), ['b', 'a']);
  });

  test('stream error becomes AsyncError', () async {
    repo.watchError = Exception('boom');
    container.invalidate(libraryViewModelProvider);
    await pumpEventQueue();
    expect(container.read(libraryViewModelProvider).hasError, isTrue);
  });

  test('deleteBook deletes and returns true', () async {
    repo.emit([bookEntry(id: 'a'), bookEntry(id: 'b')]);
    await state();

    expect(
      await container.read(libraryViewModelProvider.notifier).deleteBook('a'),
      isTrue,
    );

    expect(repo.deleted, ['a']);
    expect((await state()).books.map((b) => b.id), ['b']);
  });

  test('deleteBook returns false on error', () async {
    repo
      ..emit([bookEntry(id: 'a')])
      ..deleteError = Exception('boom');
    await state();

    expect(
      await container.read(libraryViewModelProvider.notifier).deleteBook('a'),
      isFalse,
    );

    expect(container.read(libraryViewModelProvider).hasError, isFalse);
    expect((await state()).books.map((b) => b.id), ['a']);
  });
}
