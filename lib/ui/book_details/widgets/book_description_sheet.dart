import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';

/// Gap between the top of the screen and the sheet (mockup), dp.
const double _sheetTop = 150;

/// The largest share of the screen the sheet may take.
const double _sheetMaxShare = 0.9;

/// Opens [BookDescriptionSheet] over the shell: 150 dp from the top as in the
/// mockup, but no taller than 90% of the screen.
Future<void> showBookDescription(BuildContext context, String description) {
  final screen = MediaQuery.sizeOf(context).height;
  final height = math.min(screen - _sheetTop, screen * _sheetMaxShare);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    constraints: BoxConstraints.tightFor(height: height),
    builder: (_) => BookDescriptionSheet(description: description),
  );
}

/// Full book description: paragraphs and a footnote on where the text is from.
class BookDescriptionSheet extends StatelessWidget {
  /// Creates the sheet; paragraphs of [description] are split by `\n\n`.
  const new({required this.description, super.key});

  final String description;

  static const double _titleSize = 18;
  static const FontWeight _titleWeight = FontWeight(650);
  static const double _textSize = 15.5;
  static const double _lineHeight = 25;
  static const double _noteSize = 12.5;
  static const double _closeSize = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final paragraphs = description
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty);
    return SafeArea(
      key: const Key('book_description'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s4,
              AppSpacing.s8,
              AppSpacing.s4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.bookAbout,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: _titleSize,
                        fontWeight: _titleWeight,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('book_description_close'),
                  tooltip: l10n.bookDescriptionClose,
                  constraints: const BoxConstraints.tightFor(
                    width: _closeSize,
                    height: _closeSize,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const AppIcon(AppIcons.close, size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s4,
                AppSpacing.s20,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, p) in paragraphs.indexed) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.s12),
                    Text(
                      p,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: _textSize,
                        height: _lineHeight / _textSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Divider(
            height: AppSizes.dividerThickness,
            color: scheme.outlineVariant,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: Text(
              l10n.bookDescriptionNote,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: _noteSize,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
