import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/library/view_models/library_view_model.dart';
import 'package:fusionreflow/ui/library/widgets/book_actions_dialog.dart';
import 'package:fusionreflow/ui/library/widgets/delete_book_dialog.dart';
import 'package:go_router/go_router.dart';

/// Долгое нажатие на книгу: меню действий → карточка или удаление с
/// подтверждением. Не виджет: это навигация, логики в ней нет.
Future<void> showBookActions(
  BuildContext context,
  WidgetRef ref,
  BookEntry book,
) async {
  // До await: после диалогов context уже может быть не тот.
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final l10n = AppLocalizations.of(context);
  final action = await showDialog<BookAction>(
    context: context,
    builder: (_) => BookActionsDialog(book: book),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case BookAction.details:
      await router.push<void>(AppRoutes.bookDetailsOf(book.id));
    case BookAction.delete:
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => DeleteBookDialog(book: book),
      );
      // Экран мог уйти (ошибка потока книг) за время диалога.
      if (confirmed != true || !context.mounted) return;
      final deleted = await ref
          .read(libraryViewModelProvider.notifier)
          .deleteBook(book.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(deleted ? l10n.bookDeleted : l10n.bookDeleteFailed),
        ),
      );
  }
}
