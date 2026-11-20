/// Контракт канала выбора файла между Dart и `MainActivity` (Kotlin).
///
/// Те же значения лежат в `DocumentChannel.kt`; `document_channel_test`
/// следит, чтобы копии совпадали.
abstract final class DocumentChannel {
  static const name = 'app.fusionreflow/documents';

  // Методы.
  static const methodPick = 'pick';
  static const methodOpenFd = 'openFd';

  // Аргумент `openFd` и ключи ответа `pick`.
  static const argUri = 'uri';
  static const keyUri = 'uri';
  static const keyName = 'name';
  static const keySize = 'size';

  // Коды ошибок (`PlatformException.code`).
  /// Выбор файла уже открыт.
  static const errorBusy = 'busy';

  /// Системный выбор не удалось показать или разобрать его результат.
  static const errorPickFailed = 'pick_failed';

  /// `openFd`: файл не открылся.
  static const errorNoFile = 'no_file';

  /// `openFd`: доступ к файлу отозван или файла нет.
  static const errorNoAccess = 'no_access';

  /// `openFd` вызван без `uri`.
  static const errorBadArgs = 'bad_args';

  /// Только Dart: платформа не вернула дескриптор.
  static const errorNoFd = 'no_fd';
}
