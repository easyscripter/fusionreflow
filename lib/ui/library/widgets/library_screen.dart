import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/core/widgets/section_placeholder.dart';
import 'package:go_router/go_router.dart';

/// Заглушка раздела «Library» (содержимое — в следующих задачах).
class LibraryScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('library_screen'),
      body: SectionPlaceholder(
        title: l10n.navLibrary,
        footer: kDebugMode
            ? TextButton(
                key: const Key('open_hyphen_spike'),
                onPressed: () => context.go(AppRoutes.hyphenSpike),
                child: Text(l10n.spikeOpenButton),
              )
            : null,
      ),
    );
  }
}
