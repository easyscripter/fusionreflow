import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/core/book_labels.dart';
import 'package:fusionreflow/ui/core/theme/app_cover_palette.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/library/widgets/book_cover.dart';
import 'package:go_router/go_router.dart';

/// Книга в сетке: обложка, название, автор, прогресс и формат.
class BookCard extends StatelessWidget {
  /// Creates the card.
  const new({required this.book, this.onLongPress, super.key});

  final BookEntry book;

  /// Long press: the book actions menu.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final title = book.displayTitle(l10n);
    final author = book.displayAuthors;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.control),
      onTap: () => context.push(AppRoutes.readerOf(book.id)),
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Название и автор читаются из подписей ниже, а не дважды.
          ExcludeSemantics(
            child: BookCover(
              title: title,
              author: author,
              color: AppCoverPalette.forBook(book.sourceHash),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall,
          ),
          if (author != null)
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          Text(
            book.statusLabel(l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
