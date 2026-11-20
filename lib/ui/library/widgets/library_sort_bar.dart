import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/library_sort.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/utils/window_size_class.dart';

/// Сортировка и счётчик: на телефоне чип с меню, на планшете три чипа.
class LibrarySortBar extends StatelessWidget {
  /// Creates the bar.
  const new({
    required this.sort,
    required this.totalCount,
    required this.onChanged,
    super.key,
  });

  final LibrarySort sort;
  final int totalCount;
  final ValueChanged<LibrarySort> onChanged;

  static String _label(AppLocalizations l10n, LibrarySort sort) =>
      switch (sort) {
        LibrarySort.recent => l10n.librarySortRecent,
        LibrarySort.title => l10n.librarySortTitle,
        LibrarySort.author => l10n.librarySortAuthor,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compact =
        windowSizeClassOf(MediaQuery.sizeOf(context).width) ==
        WindowSizeClass.compact;
    final theme = Theme.of(context);
    // В теме у подписи чипа нет цвета — задаём явно.
    TextStyle? chipLabel({bool selected = false}) =>
        theme.textTheme.labelMedium?.copyWith(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        );
    return Row(
      children: [
        Expanded(
          child: compact
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: MenuAnchor(
                    menuChildren: [
                      for (final value in LibrarySort.values)
                        MenuItemButton(
                          key: Key('sort_${value.name}'),
                          onPressed: () => onChanged(value),
                          child: Text(_label(l10n, value)),
                        ),
                    ],
                    builder: (context, controller, _) => ActionChip(
                      key: const Key('sort_menu'),
                      label: Text(_label(l10n, sort), style: chipLabel()),
                      avatar: const Icon(Icons.sort, size: AppSizes.icon),
                      onPressed: () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                    ),
                  ),
                )
              : Wrap(
                  spacing: AppSpacing.s8,
                  children: [
                    for (final value in LibrarySort.values)
                      ChoiceChip(
                        key: Key('sort_${value.name}'),
                        label: Text(
                          _label(l10n, value),
                          style: chipLabel(selected: value == sort),
                        ),
                        selected: value == sort,
                        onSelected: (_) => onChanged(value),
                      ),
                  ],
                ),
        ),
        Text(
          l10n.libraryBookCount(totalCount),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
