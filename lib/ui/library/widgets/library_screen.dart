import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:fusionreflow/ui/import/view_models/import_view_model.dart';
import 'package:fusionreflow/ui/import/widgets/import_message_dialog.dart';
import 'package:fusionreflow/ui/library/view_models/library_view_model.dart';
import 'package:fusionreflow/ui/library/widgets/add_book_button.dart';
import 'package:fusionreflow/ui/library/widgets/library_content.dart';
import 'package:fusionreflow/ui/library/widgets/library_empty_view.dart';
import 'package:fusionreflow/ui/library/widgets/library_error_view.dart';
import 'package:fusionreflow/ui/library/widgets/library_header.dart';
import 'package:go_router/go_router.dart';

/// Раздел «Библиотека»: книги, «Продолжить чтение», сортировка, импорт.
class LibraryScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(importViewModelProvider, (_, next) {
      final vm = ref.read(importViewModelProvider.notifier);
      switch (next) {
        case ImportAdded(:final bookId):
          context.push<void>(AppRoutes.readerOf(bookId)).ignore();
          vm.acknowledge();
        case final ImportFailedState failed:
          // Закрытие жестом или по фону — то же, что «Закрыть».
          showDialog<void>(
            context: context,
            builder: (_) => ImportMessageDialog(state: failed),
          ).then((_) => vm.dismiss()).ignore();
        case ImportPickFailed():
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).importPickFailed),
              ),
            );
          vm.dismiss();
        case ImportIdle() || ImportRunning():
      }
    });
    final library = ref.watch(libraryViewModelProvider);
    final importing = switch (ref.watch(importViewModelProvider)) {
      final ImportRunning running => running,
      _ => null,
    };
    return Scaffold(
      key: const Key('library_screen'),
      floatingActionButton: const AddBookButton(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LibraryHeader(),
            Expanded(
              child: library.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => LibraryErrorView(
                  onRetry: () => ref.invalidate(libraryViewModelProvider),
                ),
                data: (state) => state.totalCount == 0 && importing == null
                    ? const LibraryEmptyView()
                    : LibraryContent(state: state, importing: importing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
