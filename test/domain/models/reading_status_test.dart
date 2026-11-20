import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/reading_status.dart';

import '../../helpers/book_entry.dart';

void main() {
  test('fresh when never opened', () {
    expect(bookEntry().readingStatus, ReadingStatus.fresh);
  });

  test('reading when opened at zero', () {
    final book = bookEntry(lastReadAt: DateTime.utc(2026, 2));
    expect(book.readingStatus, ReadingStatus.reading);
    expect(book.progressPercent, 0);
  });

  test('finished at one', () {
    expect(bookEntry(progress: 1).readingStatus, ReadingStatus.finished);
  });

  test('percent floors and caps at 99', () {
    expect(bookEntry(progress: 0.346).progressPercent, 34);
    expect(bookEntry(progress: 0.996).progressPercent, 99);
    expect(bookEntry(progress: -0.1).progressPercent, 0);
  });
}
