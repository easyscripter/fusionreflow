import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';
import 'package:fusionreflow/ui/import/view_models/import_view_model.dart';

/// Лист «Добавить книгу»: пока один пункт — выбор файла (папка — позже).
class AddBookSheet extends ConsumerWidget {
  /// Creates the sheet.
  const new({super.key});

  static const double _rowHeight = 68;
  static const double _iconBox = 28;
  static const double _rowIcon = 22;
  static const double _chevron = 20;
  static const double _rowGap = 14;
  static const double _titleSize = 18;
  static const FontWeight _titleWeight = FontWeight(650);
  static const double _noteSize = 12.5;
  static const double _noteTop = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      // Прокрутка: при крупном шрифте лист не вмещается в 9/16 экрана.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ручку рисует тема листа (bottomSheetTheme.showDragHandle).
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s20)
                  .copyWith(top: AppSpacing.s16, bottom: AppSpacing.s8),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.importSheetTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: _titleSize,
                    fontWeight: _titleWeight,
                  ),
                ),
              ),
            ),
            Semantics(
              button: true,
              child: InkWell(
                key: const Key('pick_file'),
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(
                    ref.read(importViewModelProvider.notifier).pickAndImport(),
                  );
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _rowHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _iconBox,
                          child: AppIcon(
                            AppIcons.description,
                            size: _rowIcon,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: _rowGap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.importPickFile,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l10n.importSheetFormats,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppIcon(
                          AppIcons.chevronRight,
                          size: _chevron,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                _noteTop,
                AppSpacing.s20,
                AppSpacing.s16,
              ),
              child: Text(
                l10n.importSheetNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: _noteSize,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
