import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_placeholder_view_model.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';

void main() {
  test('finds the book by id and drops to null when it is gone', () async {
    final book = bookEntry(id: 'x');
    final repo = FakeBookRepository([book]);
    final container = ProviderContainer(
      overrides: [bookRepositoryProvider.overrideWithValue(repo)],
    )..listen(readerPlaceholderViewModelProvider('x'), (_, _) {});
    addTearDown(container.dispose);

    await pumpEventQueue();
    expect(container.read(readerPlaceholderViewModelProvider('x')).value, book);
    repo.emit([]);
    await pumpEventQueue();
    expect(
      container.read(readerPlaceholderViewModelProvider('x')).value,
      isNull,
    );
  });
}
