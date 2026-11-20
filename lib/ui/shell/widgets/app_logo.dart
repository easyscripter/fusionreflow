import 'package:flutter/material.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_brand.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';

/// Знак приложения на тёмной плашке бренда.
class AppLogo extends StatelessWidget {
  /// Creates the logo of side [size] dp.
  const new({this.size = 48, super.key});

  /// Сторона квадрата, dp.
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppBrand.background,
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      child: Image.asset(
        AppBrand.logoMarkAsset,
        width: size,
        height: size,
        semanticLabel: AppLocalizations.of(context).appTitle,
      ),
    );
  }
}
