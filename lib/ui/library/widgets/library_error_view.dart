import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';

/// Ошибка загрузки библиотеки с кнопкой «Повторить».
class LibraryErrorView extends StatelessWidget {
  /// Creates the view.
  const new({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      key: const Key('library_error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.libraryLoadError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s16),
            FilledButton(onPressed: onRetry, child: Text(l10n.libraryRetry)),
          ],
        ),
      ),
    );
  }
}
