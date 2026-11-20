import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fusionreflow/domain/models/book_format.dart';

part 'import_source.freezed.dart';

/// Файл, выбранный для импорта.
@freezed
abstract class ImportSource with _$ImportSource {
  const factory({
    /// content:// от системного выбора.
    required String uri,

    /// Имя файла для показа.
    required String name,

    /// По расширению; null — формат не поддерживается.
    BookFormat? format,
    int? sizeBytes,
  }) = _ImportSource;
}

/// Формат по расширению имени без учёта регистра; `.fb2.zip` раньше `.zip`.
BookFormat? bookFormatOfFileName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.fb2.zip')) return BookFormat.fb2Zip;
  if (lower.endsWith('.epub')) return BookFormat.epub;
  if (lower.endsWith('.fb2')) return BookFormat.fb2;
  if (lower.endsWith('.pdf')) return BookFormat.pdf;
  return null;
}

/// Имя файла без расширения формата: название, пока книги ещё нет.
String bookTitleOfFileName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.fb2.zip')) return name.substring(0, name.length - 8);
  final dot = name.lastIndexOf('.');
  return dot > 0 ? name.substring(0, dot) : name;
}
