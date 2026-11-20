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
  static const double _sideInset = 36;
  static const double _bottomInset = 72;
  static const double _extraTop = 8;
  static const double _titleSize = 21;
  static const FontWeight _titleWeight = FontWeight(650);
  static const double _titleSpacing = -0.21;
  static const double _hintSize = 13;
  static const double _formatsSize = 12.5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final body = theme.textTheme.bodyLarge?.copyWith(color: muted);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          _sideInset,
          0,
          _sideInset,
          _bottomInset,
        ),
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
            const SizedBox(height: _gap + _extraTop),
            Text(
              l10n.libraryEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: _titleSize,
                fontWeight: _titleWeight,
                letterSpacing: _titleSpacing,
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
            const SizedBox(height: _gap + _extraTop),
            Text(
              l10n.libraryEmptyHint,
              textAlign: TextAlign.center,
              style: body?.copyWith(fontSize: _hintSize),
            ),
            const SizedBox(height: _gap),
            Text(
              l10n.libraryEmptyFormats,
              textAlign: TextAlign.center,
              style: body?.copyWith(fontSize: _formatsSize),
            ),
          ],
        ),
      ),
    );
  }
}
