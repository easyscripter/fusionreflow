import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/book_labels.dart';
import 'package:fusionreflow/ui/core/theme/app_cover_palette.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';

/// Действие, выбранное в [BookActionsDialog].
enum BookAction {
  /// Открыть карточку книги.
  details,

  /// Удалить книгу (после подтверждения).
  delete,
}

/// Меню долгого нажатия на книгу: «Информация о книге» и «Удалить книгу».
/// Возвращает [BookAction] через `Navigator.pop`; «Закрыть» — null.
class BookActionsDialog extends StatelessWidget {
  /// Creates the dialog for [book].
  const new({required this.book, super.key});

  final BookEntry book;

  static const double _coverWidth = 48;
  static const double _headerGap = 14;
  static const double _titleSize = 17;
  static const FontWeight _titleWeight = FontWeight(650);
  static const double _authorSize = 13.5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final author = book.displayAuthors;

    Widget button({
      required Key key,
      required String label,
      required BookAction? action,
      required Color foreground,
      String? icon,
      Color? background,
    }) => SizedBox(
      width: double.infinity,
      child: TextButton(
        key: key,
        onPressed: () => Navigator.of(context).pop(action),
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: theme.textTheme.labelLarge,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              AppIcon(icon, size: 20, color: foreground),
              const SizedBox(width: 10),
            ],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );

    return Dialog(
      key: const Key('book_actions'),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s32,
        vertical: AppSpacing.s24,
      ),
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: l10n.bookActionsTitle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: _coverWidth,
                      child: ExcludeSemantics(
                        // Макет: на обложке 48 dp текста нет, только цвет.
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppCoverPalette.forBook(book.sourceHash),
                              borderRadius: BorderRadius.circular(
                                AppRadius.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: _headerGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.displayTitle(l10n),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: _titleSize,
                              fontWeight: _titleWeight,
                            ),
                          ),
                          if (author != null)
                            Text(
                              author,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: _authorSize,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                button(
                  key: const Key('book_action_details'),
                  label: l10n.bookActionDetails,
                  action: BookAction.details,
                  icon: AppIcons.info,
                  background: scheme.primaryContainer,
                  foreground: scheme.primary,
                ),
                const SizedBox(height: AppSpacing.s8),
                button(
                  key: const Key('book_action_delete'),
                  label: l10n.bookActionDelete,
                  action: BookAction.delete,
                  icon: AppIcons.delete,
                  background: scheme.error,
                  foreground: scheme.onError,
                ),
                const SizedBox(height: AppSpacing.s8),
                button(
                  key: const Key('book_action_close'),
                  label: l10n.bookActionClose,
                  action: null,
                  foreground: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
