import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';

/// Пункт «Настройки» внизу боковой рейки; выглядит как пункты рейки.
class RailSettingsButton extends StatelessWidget {
  /// Creates the button.
  const new({required this.selected, required this.onTap, super.key});

  /// Открыт ли раздел «Настройки».
  final bool selected;

  /// Нажатие.
  final VoidCallback onTap;

  /// Размер индикатора выбора у пунктов рейки Material 3.
  static const _indicator = Size(56, 32);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rail = theme.navigationRailTheme;
    final label = AppLocalizations.of(context).navSettings;
    final color = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_indicator.height / 2),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSizes.touchTarget,
            minHeight: AppSizes.touchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _indicator.width,
                  height: _indicator.height,
                  decoration: BoxDecoration(
                    color: selected
                        ? rail.indicatorColor ?? scheme.secondaryContainer
                        : null,
                    borderRadius: BorderRadius.circular(_indicator.height / 2),
                  ),
                  child: Center(
                    child: AppIcon(
                      AppIcons.tune,
                      size: AppSizes.icon,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  label,
                  style: selected
                      ? rail.selectedLabelTextStyle
                      : rail.unselectedLabelTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
