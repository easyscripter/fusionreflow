import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/book_details/view_models/book_details_view_model.dart';
import 'package:fusionreflow/ui/book_details/widgets/book_about_section.dart';
import 'package:fusionreflow/ui/book_details/widgets/book_details_header.dart';
import 'package:fusionreflow/ui/book_details/widgets/book_details_table.dart';
import 'package:fusionreflow/ui/book_details/widgets/book_progress_section.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';
import 'package:go_router/go_router.dart';

/// Карточка книги: шапка, прогресс, описание и детали.
class BookDetailsScreen extends ConsumerWidget {
  /// Creates the screen for book [bookId].
  const new({required this.bookId, super.key});

  final String bookId;

  static const double _backSize = 44;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final book = ref.watch(bookDetailsViewModelProvider(bookId));
    final message = Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: book.hasError
            ? Text(l10n.libraryLoadError, key: const Key('book_load_error'))
            : Text(l10n.readerBookNotFound, key: const Key('book_not_found')),
      ),
    );
    return Scaffold(
      key: const Key('book_details'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.detailsMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s8,
                    10,
                    AppSpacing.s8,
                    0,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      key: const Key('book_back'),
                      tooltip: l10n.bookBack,
                      constraints: const BoxConstraints.tightFor(
                        width: _backSize,
                        height: _backSize,
                      ),
                      onPressed: context.pop,
                      icon: const AppIcon(AppIcons.chevronLeft),
                    ),
                  ),
                ),
                Expanded(
                  child: switch (book) {
                    AsyncData(value: final entry?) => ListView(
                      children: [
                        BookDetailsHeader(book: entry),
                        BookProgressSection(book: entry),
                        const SizedBox(height: AppSpacing.s12),
                        BookAboutSection(description: entry.description),
                        BookDetailsTable(book: entry),
                      ],
                    ),
                    AsyncLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    _ => message,
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
