import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';
import 'package:fusionreflow/ui/shell/widgets/app_logo.dart';
import 'package:fusionreflow/ui/shell/widgets/rail_settings_button.dart';
import 'package:fusionreflow/utils/window_size_class.dart';
import 'package:go_router/go_router.dart';

/// Оболочка приложения: нижняя панель на телефоне, боковая рейка на планшете.
class AppShell extends StatelessWidget {
  /// Creates the shell around the current section.
  const new({required this.navigationShell, super.key});

  /// Разделы (ветки роутера).
  final StatefulNavigationShell navigationShell;

  static const _library = 0;
  static const _settings = 2;

  void _select(int index) => navigationShell.goBranch(
    index,
    // Повторный тап по активному пункту возвращает в корень раздела.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index = navigationShell.currentIndex;
    final wide =
        windowSizeClassOf(MediaQuery.sizeOf(context).width) !=
        WindowSizeClass.compact;
    return PopScope(
      // «Назад» с корня Закладок/Настроек ведёт в Библиотеку, а не из приложения.
      // Внутри раздела сначала сработает pop его собственного стека.
      canPop: index == _library,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(_library);
      },
      child: Scaffold(
        body: wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: index == _settings ? null : index,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    leading: const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.s16),
                      child: AppLogo(),
                    ),
                    trailing: RailSettingsButton(
                      selected: index == _settings,
                      onTap: () => _select(_settings),
                    ),
                    trailingAtBottom: true,
                    destinations: [
                      NavigationRailDestination(
                        icon: const AppIcon(AppIcons.menuBook),
                        label: Text(l10n.navLibrary),
                      ),
                      NavigationRailDestination(
                        icon: const AppIcon(AppIcons.bookmark),
                        label: Text(l10n.navBookmarks),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: AppSizes.dividerThickness),
                  Expanded(child: navigationShell),
                ],
              )
            : navigationShell,
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: index,
                onDestinationSelected: _select,
                destinations: [
                  NavigationDestination(
                    icon: const AppIcon(AppIcons.menuBook),
                    label: l10n.navLibrary,
                  ),
                  NavigationDestination(
                    icon: const AppIcon(AppIcons.bookmark),
                    label: l10n.navBookmarks,
                  ),
                  NavigationDestination(
                    icon: const AppIcon(AppIcons.tune),
                    label: l10n.navSettings,
                  ),
                ],
              ),
      ),
    );
  }
}
