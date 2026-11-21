import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/library/view_models/library_view_model.dart';
import 'package:fusionreflow/ui/library/widgets/book_actions_dialog.dart';
import 'package:fusionreflow/ui/library/widgets/delete_book_dialog.dart';
import 'package:go_router/go_router.dart';

/// Long press on a book: actions menu → book card, or delete with a
/// confirmation. Not a widget: it is navigation, there is no logic in it.
Future<void> showBookActions(
  BuildContext context,
  WidgetRef ref,
  BookEntry book,
) async {
  // Taken before the first await: after the dialogs the context may be gone.
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
      // The screen may be gone (the book stream failed) during the dialog.
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
