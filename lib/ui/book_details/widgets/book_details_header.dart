import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/book_labels.dart';
import 'package:fusionreflow/ui/core/file_size_label.dart';
import 'package:fusionreflow/ui/core/language_label.dart';
import 'package:fusionreflow/ui/core/theme/app_cover_palette.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/library/widgets/book_cover.dart';

/// Шапка карточки: обложка, название, авторы и строка «формат · размер · язык».
class BookDetailsHeader extends StatelessWidget {
  /// Creates the header for [book].
  const new({required this.book, super.key});

  final BookEntry book;

  static const double _coverWidth = 104;
  static const double _titleSize = 24;
  static const double _titleHeight = 30;
  static const FontWeight _titleWeight = FontWeight(650);
  static const List<BoxShadow> _coverShadow = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 28, offset: Offset(0, 10)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final title = book.displayTitle(l10n);
    final author = book.displayAuthors;
    final size = book.sourceSize;
    final meta = [
      book.format.label(l10n),
      if (size != null) fileSizeLabel(l10n, size),
      ?languageLabel(context, book.language),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s4,
        AppSpacing.s24,
        0,
      ),
      child: Column(
        children: [
          // Название и авторы читаются из подписей ниже, а не дважды.
          ExcludeSemantics(
            child: SizedBox(
              width: _coverWidth,
              child: DecoratedBox(
                decoration: const BoxDecoration(boxShadow: _coverShadow),
                child: BookCover(
                  title: title,
                  author: author,
                  color: AppCoverPalette.forBook(book.sourceHash),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: _titleSize,
              height: _titleHeight / _titleSize,
              fontWeight: _titleWeight,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            author ?? l10n.bookNoAuthor,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted,
              fontStyle: author == null ? FontStyle.italic : null,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            meta,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}
