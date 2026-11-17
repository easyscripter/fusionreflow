/// Линейные иконки приложения из дизайн-системы (сетка 24 dp, штрих 1,8).
///
/// Имена совпадают с именами из `Icons`. В репозитории пока только значки
/// навигации; остальные из доски «Иконки» добавляются по мере появления
/// экранов.
abstract final class AppIcons {
  static const menuBook = 'assets/icons/menu_book.svg';
  static const bookmark = 'assets/icons/bookmark.svg';
  static const tune = 'assets/icons/tune.svg';

  /// Все иконки (для проверки, что файлы лежат в сборке).
  static const List<String> all = [menuBook, bookmark, tune];
}
