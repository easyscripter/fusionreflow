import 'package:fusionreflow/domain/models/book_entry.dart';

/// Где книга относительно чтения.
enum ReadingStatus { fresh, reading, finished }

/// Статус и процент чтения книги каталога.
extension BookReadingStatus on BookEntry {
  /// fresh: не открывалась и progress == 0; finished: progress >= 1.
  ReadingStatus get readingStatus {
    if (progress >= 1) return ReadingStatus.finished;
    if (lastReadAt == null && progress == 0) return ReadingStatus.fresh;
    return ReadingStatus.reading;
  }

  /// floor(progress * 100) в 0..99: 99,6% не показывается как 100%.
  int get progressPercent => (progress * 100).floor().clamp(0, 99);
}
