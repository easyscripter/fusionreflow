import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/domain/models/reading_status.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/book_labels.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_placeholder_view_model.dart';

/// Заглушка читалки: название и позиция; настоящую читалку даёт 5.3.
class ReaderPlaceholderScreen extends ConsumerWidget {
  /// Creates the screen for book [bookId].
  const new({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final book = ref.watch(readerPlaceholderViewModelProvider(bookId));
    return Scaffold(
      key: const Key('reader_placeholder'),
      appBar: AppBar(
        title: Text(
          book.value?.displayTitle(l10n) ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: book.when(
            loading: CircularProgressIndicator.new,
            error: (_, _) => Text(l10n.readerBookNotFound),
            data: (entry) => entry == null
                ? Text(l10n.readerBookNotFound)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.displayTitle(l10n),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(l10n.readerPlaceholderTitle),
                      Text(
                        l10n.readerPlaceholderPosition(entry.progressPercent),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
