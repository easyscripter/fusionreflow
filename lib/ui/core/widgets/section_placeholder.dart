import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/utils/window_size_class.dart';

/// Заглушка раздела: заголовок вверху, «раздел появится позже» по центру.
class SectionPlaceholder extends StatelessWidget {
  /// Creates the placeholder; [footer] goes under the "coming soon" line.
  const new({required this.title, this.footer, super.key});

  /// Название раздела.
  final String title;

  /// Необязательный виджет под сообщением.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact =
        windowSizeClassOf(MediaQuery.sizeOf(context).width) ==
        WindowSizeClass.compact;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s20,
              compact ? AppSpacing.s16 : AppSpacing.s32,
              AppSpacing.s20,
              0,
            ),
            child: Text(title, style: theme.textTheme.headlineMedium),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).sectionComingSoon,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  ?footer,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
