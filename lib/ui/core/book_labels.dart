import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/reading_status.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';

/// Подписи книги для экранов: пустое название и авторы не ломают вёрстку.
extension BookLabels on BookEntry {
  /// Название; пустое — «Без названия».
  String displayTitle(AppLocalizations l10n) =>
      title.trim().isEmpty ? l10n.libraryUntitled : title;

  /// Авторы через «, »; null, если авторов нет.
  String? get displayAuthors {
    final names = authors.map((a) => a.trim()).where((a) => a.isNotEmpty);
    return names.isEmpty ? null : names.join(', ');
  }

  /// «72% · EPUB», «Новая · EPUB», «Прочитана · FB2».
  String statusLabel(AppLocalizations l10n) {
    final status = switch (readingStatus) {
      ReadingStatus.fresh => l10n.libraryStatusNew,
      ReadingStatus.reading => l10n.libraryPercent(progressPercent),
      ReadingStatus.finished => l10n.libraryStatusFinished,
    };
    return '$status · ${format.label(l10n)}';
  }
}

/// Название формата для показа.
extension BookFormatLabel on BookFormat {
  String label(AppLocalizations l10n) => switch (this) {
    BookFormat.pdf => l10n.bookFormatPdf,
    BookFormat.epub => l10n.bookFormatEpub,
    BookFormat.fb2 => l10n.bookFormatFb2,
    BookFormat.fb2Zip => l10n.bookFormatFb2Zip,
  };
}
