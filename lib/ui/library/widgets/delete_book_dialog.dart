import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/book_labels.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';

/// Delete confirmation. Pops true when the user confirms.
class DeleteBookDialog extends StatelessWidget {
  /// Creates the dialog for [book].
  const new({required this.book, super.key});

  final BookEntry book;

  static const double _messageSize = 14.5;
  static const double _messageHeight = 21;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge;
    ButtonStyle style(Color color) => TextButton.styleFrom(
      minimumSize: const Size(0, AppSizes.buttonHeight),
      foregroundColor: color,
      textStyle: textStyle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
    );
    return AlertDialog(
      key: const Key('book_delete'),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s32,
        vertical: AppSpacing.s24,
      ),
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      title: Text(l10n.bookDeleteTitle),
      content: Text(
        l10n.bookDeleteMessage(book.displayTitle(l10n)),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: _messageSize,
          height: _messageHeight / _messageSize,
          color: scheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          key: const Key('delete_cancel'),
          style: style(scheme.primary),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.bookDeleteCancel),
        ),
        TextButton(
          key: const Key('delete_confirm'),
          style: style(scheme.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.bookDeleteConfirm),
        ),
      ],
    );
  }
}
