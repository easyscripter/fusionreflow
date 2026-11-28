import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/reader_palette.dart';

/// A message in place of the page (book not found, cannot be opened) with a
/// back button.
class ReaderMessageView extends StatelessWidget {
  const new({
    required this.message,
    required this.palette,
    required this.onBack,
    super.key,
  });

  final String message;
  final ReaderPalette palette;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s12,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: palette.pageText,
            ),
          ),
          TextButton(
            onPressed: onBack,
            style: TextButton.styleFrom(
              foregroundColor: palette.accent,
              minimumSize: const Size(0, 48),
              textStyle: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            child: Text(AppLocalizations.of(context).readerBack),
          ),
        ],
      ),
    ),
  );
}
