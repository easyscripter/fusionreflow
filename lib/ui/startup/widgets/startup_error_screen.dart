import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';

/// Экран ошибки запуска с кнопкой «Повторить». Подробности ошибки не
/// показываются.
class StartupErrorScreen extends StatelessWidget {
  /// Creates the screen; [onRetry] restarts the initialisation.
  const new({required this.onRetry, super.key});

  /// Повторить запуск.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      key: const Key('startup_error'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                l10n.startupErrorTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                l10n.startupErrorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s24),
              FilledButton(onPressed: onRetry, child: Text(l10n.startupRetry)),
            ],
          ),
        ),
      ),
    );
  }
}
