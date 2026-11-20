/// Линейные иконки приложения из дизайн-системы (сетка 24 dp, штрих 1,8).
///
/// Имена совпадают с именами из `Icons`. В репозитории пока только значки
/// навигации; остальные из доски «Иконки» добавляются по мере появления
/// экранов.
abstract final class AppIcons {
  static const menuBook = 'assets/icons/menu_book.svg';
  static const bookmark = 'assets/icons/bookmark.svg';
  static const tune = 'assets/icons/tune.svg';
  static const sort = 'assets/icons/sort.svg';
  static const chevronDown = 'assets/icons/chevron_down.svg';
  static const chevronRight = 'assets/icons/chevron_right.svg';
  static const description = 'assets/icons/description.svg';
  static const info = 'assets/icons/info.svg';
  static const delete = 'assets/icons/delete.svg';
  static const chevronLeft = 'assets/icons/chevron_left.svg';
  static const close = 'assets/icons/close.svg';

  /// Иллюстрация пустой библиотеки (viewBox 128×112, не квадратная).
  static const libraryEmpty = 'assets/icons/library_empty.svg';

  /// Все иконки (для проверки, что файлы лежат в сборке).
  static const List<String> all = [
    menuBook,
    bookmark,
    tune,
    sort,
    chevronDown,
    chevronRight,
    description,
    info,
    delete,
    chevronLeft,
    close,
    libraryEmpty,
  ];
}
