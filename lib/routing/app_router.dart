import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/bookmarks/widgets/bookmarks_screen.dart';
import 'package:fusionreflow/ui/library/widgets/library_screen.dart';
import 'package:fusionreflow/ui/settings/widgets/settings_screen.dart';
import 'package:fusionreflow/ui/shell/widgets/app_shell.dart';
import 'package:fusionreflow/ui/spikes/widgets/hyphen_spike_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Собирает роутер: оболочка с тремя ветками (Библиотека, Закладки,
/// Настройки). Отдельная функция, чтобы тесты стартовали с любого пути.
GoRouter createAppRouter({String initialLocation = AppRoutes.library}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) =>
        state.error != null ? AppRoutes.library : null,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(),
            routes: [
              GoRoute(
                path: AppRoutes.library,
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  if (kDebugMode)
                    GoRoute(
                      path: 'hyphen-spike',
                      builder: (context, state) => const HyphenSpikeScreen(),
                    ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(),
            routes: [
              GoRoute(
                path: AppRoutes.bookmarks,
                builder: (context, state) => const BookmarksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(),
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Роутер приложения.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
}
