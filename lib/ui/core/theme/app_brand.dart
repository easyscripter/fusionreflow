import 'dart:ui';

/// Константы бренда (логотип, фон сплеша и иконки).
abstract final class AppBrand {
  /// Фон сплеша, иконки и плашки логотипа (#0C0F22).
  ///
  /// Тот же цвет — `brand_background` в
  /// `android/app/src/main/res/values/brand_colors.xml` (ресурс другой платформы,
  /// общего источника нет; при правке менять оба). Совпадает с
  /// `darkColorScheme.surfaceContainerLowest`, но это другое знание: бренд и
  /// тема меняются по разным причинам, поэтому цвет не берётся из темы.
  static const Color background = Color(0xFF0C0F22);

  /// Знак логотипа (книга с волнами) на прозрачном фоне.
  static const String logoMarkAsset = 'assets/branding/logo_mark.png';
}
