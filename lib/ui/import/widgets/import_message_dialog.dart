import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/domain/models/import_update.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:fusionreflow/ui/import/view_models/import_view_model.dart';
import 'package:fusionreflow/utils/window_size_class.dart';

/// Карточка результата импорта: на телефоне — экран, на планшете — диалог.
class ImportMessageDialog extends ConsumerWidget {
  /// Creates the card for a [state] that failed.
  const new({required this.state, super.key});

  final ImportFailedState state;

  static const double _dialogWidth = 420;
  static const double _bytesInMb = 1048576;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final vm = ref.read(importViewModelProvider.notifier);
    final compact =
        windowSizeClassOf(MediaQuery.sizeOf(context).width) ==
        WindowSizeClass.compact;

    // Закрываем окно, потом сообщаем ViewModel.
    Widget button(String label, VoidCallback action, {bool primary = false}) {
      void onPressed() {
        Navigator.of(context).pop();
        action();
      }

      return SizedBox(
        width: double.infinity,
        child: primary
            ? FilledButton(onPressed: onPressed, child: Text(label))
            : OutlinedButton(onPressed: onPressed, child: Text(label)),
      );
    }

    void pick() {
      vm
        ..dismiss()
        ..pickAndImport().ignore();
    }

    final (title, message, buttons) = switch (state.failure) {
      ImportFailure.pdfNotYet => (
        l10n.importPdfLaterTitle,
        l10n.importPdfLaterMessage,
        [
          button(l10n.importPickEpubOrFb2, pick, primary: true),
          button(l10n.importGotIt, vm.dismiss),
        ],
      ),
      ImportFailure.unsupportedFormat => (
        l10n.importUnsupportedTitle,
        l10n.importUnsupportedMessage,
        [button(l10n.importGotIt, vm.dismiss, primary: true)],
      ),
      ImportFailure.unreadable => (
        l10n.importUnreadableTitle,
        l10n.importUnreadableMessage,
        [button(l10n.importPickOther, pick, primary: true)],
      ),
      ImportFailure.noAccess => (
        l10n.importNoAccessTitle,
        l10n.importNoAccessMessage,
        [button(l10n.importPickFile, pick, primary: true)],
      ),
      ImportFailure.cancelled => (
        l10n.importCancelledTitle,
        l10n.importCancelledMessage,
        [
          button(l10n.importRetry, () => vm.retry().ignore(), primary: true),
          button(l10n.importClose, vm.dismiss),
        ],
      ),
    };

    final size = state.source.sizeBytes;
    final pdfNote = state.failure == ImportFailure.pdfNotYet
        ? (size == null
              ? l10n.importPdfLaterFileNoSize
              : l10n.importPdfLaterFile(l10n.fileSizeMb(size / _bytesInMb)))
        : null;

    final content = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (pdfNote != null) ...[
              const SizedBox(height: AppSpacing.s16),
              Text(
                state.source.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                pdfNote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.s24),
            for (final b in buttons) ...[
              b,
              const SizedBox(height: AppSpacing.s8),
            ],
          ],
        ),
      ),
    );

    return compact
        ? Dialog.fullscreen(child: content)
        : Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _dialogWidth),
              child: content,
            ),
          );
  }
}
