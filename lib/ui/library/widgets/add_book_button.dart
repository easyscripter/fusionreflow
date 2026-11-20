import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:fusionreflow/ui/import/view_models/import_view_model.dart';

/// «Добавить»: открывает выбор файла; во время импорта — SnackBar.
class AddBookButton extends ConsumerWidget {
  /// Creates the button.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FloatingActionButton.extended(
      tooltip: l10n.libraryAddSemantics,
      key: const Key('add_book'),
      onPressed: () {
        if (ref.read(importViewModelProvider) is ImportRunning) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.importBusy)));
          return;
        }
        ref.read(importViewModelProvider.notifier).pickAndImport().ignore();
      },
      icon: const Icon(Icons.add),
      label: Text(l10n.libraryAdd),
    );
  }
}
