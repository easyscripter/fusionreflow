import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';

/// Иконка приложения из [AppIcons](../theme/app_icons.dart): размер и цвет —
/// из `IconTheme` (так её красят панель, рейка, кнопки), если не заданы явно.
class AppIcon extends StatelessWidget {
  /// Creates the icon from an `AppIcons` asset path.
  const new(this.asset, {this.size, this.color, super.key});

  /// Путь к SVG из `AppIcons`.
  final String asset;

  /// Размер, dp; по умолчанию из темы иконок.
  final double? size;

  /// Цвет; по умолчанию из темы иконок.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? AppSizes.icon;
    final tint =
        color ?? theme.color ?? Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      asset,
      width: side,
      height: side,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
