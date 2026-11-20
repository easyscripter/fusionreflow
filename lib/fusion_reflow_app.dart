import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_router.dart';
import 'package:fusionreflow/ui/core/theme/app_theme.dart';
import 'package:fusionreflow/ui/startup/widgets/startup_gate.dart';

/// Корень приложения.
class FusionReflowApp extends ConsumerWidget {
  /// Creates the app.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // ignore: avoid_redundant_argument_values (режим «системная» — явно)
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) =>
          StartupGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
