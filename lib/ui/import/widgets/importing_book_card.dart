import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_cover_palette.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:fusionreflow/ui/import/view_models/import_view_model.dart';
import 'package:fusionreflow/ui/library/widgets/book_cover.dart';

/// Карточка конвертации в сетке: прогресс и «Отменить».
class ImportingBookCard extends ConsumerWidget {
  /// Creates the card for a running import.
  const new({required this.state, super.key});

  final ImportRunning state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final done = state.done;
    final total = state.total;
    final known = done != null && total != null && total > 0;
    return Column(
      key: const Key('importing_book'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookCover(
          title: bookTitleOfFileName(state.source.name),
          color: AppCoverPalette.forName(state.source.name),
          child: ColoredBox(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                value: known ? (done / total).clamp(0, 1) : null,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          bookTitleOfFileName(state.source.name),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.titleSmall,
        ),
        if (known)
          Text(
            l10n.importProgress(done, total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall,
          ),
        TextButton(
          key: const Key('cancel_import'),
          onPressed: () => ref.read(importViewModelProvider.notifier).cancel(),
          child: Text(l10n.importCancel),
        ),
      ],
    );
  }
}
