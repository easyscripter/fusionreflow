import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';

/// Пустая библиотека: что добавить и как.
class LibraryEmptyView extends StatelessWidget {
  /// Creates the view.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: muted),
            const SizedBox(height: AppSpacing.s16),
            Text(
              l10n.libraryEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              l10n.libraryEmptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              l10n.libraryEmptyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.libraryEmptyFormats,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
