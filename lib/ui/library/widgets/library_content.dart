import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:fusionreflow/ui/library/view_models/library_state.dart';
import 'package:fusionreflow/ui/library/view_models/library_view_model.dart';
import 'package:fusionreflow/ui/library/widgets/book_grid.dart';
import 'package:fusionreflow/ui/library/widgets/continue_reading_card.dart';
import 'package:fusionreflow/ui/library/widgets/library_sort_bar.dart';

/// Книги библиотеки: «Продолжить чтение», сортировка и сетка.
class LibraryContent extends ConsumerWidget {
  const new({required this.state, required this.importing, super.key});

  final LibraryState state;
  final ImportRunning? importing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hero = state.continueReading;
    const side = EdgeInsets.symmetric(horizontal: AppSpacing.s20);
    return CustomScrollView(
      slivers: [
        if (hero != null)
          SliverPadding(
            padding: side.copyWith(top: AppSpacing.s16),
            sliver: SliverToBoxAdapter(child: ContinueReadingCard(book: hero)),
          ),
        SliverPadding(
          padding: side.copyWith(top: AppSpacing.s16),
          sliver: SliverToBoxAdapter(
            child: LibrarySortBar(
              sort: state.sort,
              totalCount: state.totalCount,
              // Нотификатор берём в момент тапа, а не при сборке виджета.
              onChanged: (sort) =>
                  ref.read(libraryViewModelProvider.notifier).setSort(sort),
            ),
          ),
        ),
        BookGrid(books: state.books, importing: importing),
      ],
    );
  }
}
