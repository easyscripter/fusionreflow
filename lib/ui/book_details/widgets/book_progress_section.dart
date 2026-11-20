import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/reading_status.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:go_router/go_router.dart';

/// Статус чтения, полоса прогресса и кнопка «Начать / Продолжить чтение».
class BookProgressSection extends StatelessWidget {
  /// Creates the section for [book].
  const new({required this.book, super.key});

  final BookEntry book;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = book.readingStatus;
    final label = switch (status) {
      ReadingStatus.fresh => l10n.bookNotStarted,
      ReadingStatus.reading => l10n.bookReadPercent(book.progressPercent),
      ReadingStatus.finished => l10n.bookFinished,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          LinearProgressIndicator(
            value: book.progress.clamp(0, 1),
            minHeight: AppSizes.trackHeight,
            semanticsLabel: label,
          ),
          const SizedBox(height: AppSpacing.s16),
          FilledButton(
            key: const Key('book_read'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
            ),
            onPressed: () => context.push(AppRoutes.readerOf(book.id)),
            child: Text(
              status == ReadingStatus.fresh
                  ? l10n.bookStartReading
                  : l10n.bookContinueReading,
            ),
          ),
        ],
      ),
    );
  }
}
