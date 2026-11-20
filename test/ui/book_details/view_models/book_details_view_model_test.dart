import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/ui/book_details/view_models/book_details_view_model.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';

void main() {
  test('follows the book and becomes null on delete', () async {
    final book = bookEntry(id: 'x');
    final repo = FakeBookRepository([book]);
    final container = ProviderContainer(
      overrides: [bookRepositoryProvider.overrideWithValue(repo)],
    )..listen(bookDetailsViewModelProvider('x'), (_, _) {});
    addTearDown(container.dispose);

    await pumpEventQueue();
    expect(container.read(bookDetailsViewModelProvider('x')).value, book);
    await repo.delete('x');
    await pumpEventQueue();
    expect(container.read(bookDetailsViewModelProvider('x')).value, isNull);
  });
}
