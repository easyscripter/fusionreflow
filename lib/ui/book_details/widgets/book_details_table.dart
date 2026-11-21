import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/book_labels.dart';
import 'package:fusionreflow/ui/core/file_size_label.dart';
import 'package:fusionreflow/ui/core/language_label.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:intl/intl.dart';

/// "Details": format, file size, language and date added.
class BookDetailsTable extends StatelessWidget {
  /// Creates the table for [book].
  const new({required this.book, super.key});

  final BookEntry book;

  static const double _rowPadding = 5;
  static const double _rowTextSize = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final size = book.sourceSize;
    final language = languageLabel(context, book.language);
    final added = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(book.addedAt);

    Widget row(String name, Widget value) => DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _rowPadding),
        // Both are Flexible: at a large font the label and the value wrap.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: _rowTextSize,
                  color: muted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Flexible(child: value),
          ],
        ),
      ),
    );

    Widget text(String value, {Color? color}) => Text(
      value,
      textAlign: TextAlign.end,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: _rowTextSize,
        color: color,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        AppSpacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.bookDetailsTitle,
              style: theme.textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 2),
          row(l10n.bookDetailFormat, text(book.format.label(l10n))),
          if (size != null)
            row(l10n.bookDetailSize, text(fileSizeLabel(l10n, size))),
          row(
            l10n.bookDetailLanguage,
            language == null
                ? text(l10n.bookLanguageUnknown, color: muted)
                : text(language),
          ),
          row(l10n.bookDetailAdded, text(added)),
        ],
      ),
    );
  }
}
