import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';

/// Пустая библиотека: что добавить и как (макет `library-empty`).
class LibraryEmptyView extends StatelessWidget {
  /// Creates the view.
  const new({super.key});

  static const double _artWidth = 140;
  static const double _artHeight = 120;
  static const double _gap = 12;
  static const double _textMaxWidth = 290;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final body = theme.textTheme.bodyLarge?.copyWith(color: muted);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 0, 36, 72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: const Key('library_empty_art'),
              width: _artWidth,
              height: _artHeight,
              child: SvgPicture.asset(
                AppIcons.libraryEmpty,
                colorFilter: ColorFilter.mode(muted, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: _gap + 8),
            Text(
              l10n.libraryEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 21,
                fontWeight: const FontWeight(650),
                letterSpacing: -0.21,
              ),
            ),
            const SizedBox(height: _gap),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _textMaxWidth),
              child: Text(
                l10n.libraryEmptyMessage,
                textAlign: TextAlign.center,
                style: body,
              ),
            ),
            const SizedBox(height: _gap + 8),
            Text(
              l10n.libraryEmptyHint,
              textAlign: TextAlign.center,
              style: body?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: _gap),
            Text(
              l10n.libraryEmptyFormats,
              textAlign: TextAlign.center,
              style: body?.copyWith(fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}
