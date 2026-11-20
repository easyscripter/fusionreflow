import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/book_details/widgets/book_description_sheet.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';

/// «Об этой книге»: описание в две строки и «Читать полностью», если оно
/// длиннее. Без описания — «В файле нет описания.».
class BookAboutSection extends StatelessWidget {
  /// Creates the section; [description] is plain text with `\n\n` paragraphs.
  const new({required this.description, super.key});

  final String? description;

  static const int _previewLines = 2;
  static const double _textSize = 14;
  static const double _lineHeight = 22;
  static const double _linkHeight = 32;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = description?.trim() ?? '';
    final style = theme.textTheme.bodyMedium?.copyWith(
      fontSize: _textSize,
      height: _lineHeight / _textSize,
      color: theme.colorScheme.onSurfaceVariant,
    );
    // В превью абзацы идут подряд: пустая строка съела бы одну из двух.
    final preview = text.split('\n\n').join(' ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final overflows =
              text.isNotEmpty &&
              (TextPainter(
                text: TextSpan(text: preview, style: style),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
                maxLines: _previewLines,
              )..layout(maxWidth: constraints.maxWidth)).didExceedMaxLines;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wrap: при крупном шрифте ссылка уходит на строку ниже.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.bookAbout,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  if (overflows)
                    TextButton(
                      key: const Key('book_read_more'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, _linkHeight),
                        textStyle: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => showBookDescription(context, text),
                      child: Text(l10n.bookReadMore),
                    ),
                ],
              ),
              Text(
                text.isEmpty ? l10n.bookNoDescription : preview,
                maxLines: _previewLines,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ],
          );
        },
      ),
    );
  }
}
