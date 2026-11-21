import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/reading_status.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/core/book_labels.dart';
import 'package:fusionreflow/ui/core/theme/app_cover_palette.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/library/widgets/book_cover.dart';
import 'package:fusionreflow/utils/window_size_class.dart';
import 'package:go_router/go_router.dart';

/// «Продолжить чтение»: обложка, название, «автор · N%», полоса прогресса.
class ContinueReadingCard extends StatelessWidget {
  /// Creates the card.
  const new({required this.book, this.onLongPress, super.key});

  final BookEntry book;

  /// Long press: the book actions menu.
  final VoidCallback? onLongPress;

  static const double _coverWidth = 72;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final compact =
        windowSizeClassOf(MediaQuery.sizeOf(context).width) ==
        WindowSizeClass.compact;
    final title = book.displayTitle(l10n);
    final author = book.displayAuthors;
    final percent = l10n.libraryPercent(book.progressPercent);
    void open() => context.push(AppRoutes.readerOf(book.id));
    return Card(
      key: const Key('continue_reading'),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
        onTap: open,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Row(
            children: [
              SizedBox(
                width: _coverWidth,
                child: ExcludeSemantics(
                  child: BookCover(
                    title: title,
                    author: author,
                    color: AppCoverPalette.forBook(book.sourceHash),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.libraryContinueReading,
                      style: text.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    Text(
                      author == null ? percent : '$author · $percent',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    LinearProgressIndicator(
                      value: book.progress.clamp(0, 1),
                      minHeight: AppSizes.trackHeight,
                      semanticsLabel: percent,
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: AppSpacing.s16),
                FilledButton(onPressed: open, child: Text(l10n.libraryRead)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
