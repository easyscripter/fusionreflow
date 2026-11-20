import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/reading_position.dart';

/// Catalog entry with defaults, so tests state only what matters to them.
BookEntry bookEntry({
  String id = 'id',
  String title = 'Title',
  List<String> authors = const ['Author'],
  BookFormat format = BookFormat.epub,
  String sourceHash = '00',
  DateTime? addedAt,
  ReadingPosition position = ReadingPosition.start,
  double progress = 0,
  DateTime? lastReadAt,
  String? language,
  String? description,
  int? sourceSize,
}) => BookEntry(
  id: id,
  title: title,
  authors: authors,
  format: format,
  sourceHash: sourceHash,
  converterVersion: 'test',
  addedAt: addedAt ?? DateTime.utc(2026),
  position: position,
  progress: progress,
  lastReadAt: lastReadAt,
  language: language,
  description: description,
  sourceSize: sourceSize,
);
