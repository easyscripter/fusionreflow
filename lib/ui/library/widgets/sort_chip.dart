import 'package:flutter/material.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';

/// Чип выбора сортировки: иконка, название, стрелка вниз (макет `library`).
class SortChip extends StatelessWidget {
  /// Creates the chip.
  const new({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
    );
    return Material(
      color: scheme.surfaceContainerHighest,
      shape: shape,
      child: Semantics(
        button: true,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.chipHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(AppIcons.sort, size: 16, color: scheme.onSurface),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AppIcon(
                    AppIcons.chevronDown,
                    size: 14,
                    color: scheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
