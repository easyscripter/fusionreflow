import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:fusionreflow/ui/import/widgets/importing_book_card.dart';
import 'package:fusionreflow/ui/library/widgets/book_card.dart';

/// Ленивая сетка книг (sliver); при импорте первой идёт карточка конвертации.
class BookGrid extends StatelessWidget {
  /// Creates the grid.
  const new({required this.books, this.importing, super.key});

  final List<BookEntry> books;
  final ImportRunning? importing;

  /// Ширина колонки не меньше этого значения, dp.
  static const double columnWidth = 150;

  /// Высота подписей под обложкой при масштабе шрифта 1.0, dp.
  static const double _captionHeight = 96;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final extra = importing == null ? 0 : 1;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent - 2 * AppSpacing.s20;
        final columns = math.max(2, width ~/ columnWidth);
        final cell = (width - (columns - 1) * AppSpacing.s16) / columns;
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s12,
            AppSpacing.s20,
            AppSizes.fabHeight + AppSpacing.s32,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.s16,
              crossAxisSpacing: AppSpacing.s16,
              mainAxisExtent: cell * 1.5 + scaler.scale(_captionHeight),
            ),
            itemCount: books.length + extra,
            itemBuilder: (context, i) {
              final running = importing;
              if (running != null && i == 0) {
                return ImportingBookCard(state: running);
              }
              return BookCard(book: books[i - extra]);
            },
          ),
        );
      },
    );
  }
}
