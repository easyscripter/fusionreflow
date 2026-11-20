/// Пути приложения.
abstract final class AppRoutes {
  static const library = '/library';
  static const bookmarks = '/bookmarks';
  static const settings = '/settings';

  /// Заглушка читалки; открывается поверх оболочки через `push`.
  static const reader = '/reader/:bookId';

  static String readerOf(String bookId) =>
      '/reader/${Uri.encodeComponent(bookId)}';

  /// Только debug-сборка.
  static const hyphenSpike = '/library/hyphen-spike';
}
