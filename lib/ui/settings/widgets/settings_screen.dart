import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/widgets/section_placeholder.dart';

/// Заглушка раздела «Настройки» (содержимое — в следующих задачах).
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('settings_screen'),
      body: SectionPlaceholder(title: l10n.navSettings),
    );
  }
}
