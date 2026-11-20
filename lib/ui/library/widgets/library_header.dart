import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/utils/window_size_class.dart';
import 'package:go_router/go_router.dart';

/// Заголовок «Библиотека»; в debug — меню ⋮ со спайком переносов.
class LibraryHeader extends StatelessWidget {
  /// Creates the header.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compact =
        windowSizeClassOf(MediaQuery.sizeOf(context).width) ==
        WindowSizeClass.compact;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        compact ? AppSpacing.s16 : AppSpacing.s32,
        AppSpacing.s8,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.navLibrary,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          if (kDebugMode)
            PopupMenuButton<void>(
              key: const Key('library_debug_menu'),
              tooltip: l10n.libraryDebugMenu,
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  key: const Key('open_hyphen_spike'),
                  onTap: () => context.go(AppRoutes.hyphenSpike),
                  child: Text(l10n.spikeOpenButton),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
