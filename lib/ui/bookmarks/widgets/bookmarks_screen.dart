import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/widgets/section_placeholder.dart';

/// Заглушка раздела «Закладки» (содержимое — в следующих задачах).
class BookmarksScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('bookmarks_screen'),
      body: SectionPlaceholder(title: l10n.navBookmarks),
    );
  }
}
