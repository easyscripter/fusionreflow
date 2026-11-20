/// Общие константы приложения.
library;

/// Сколько секунд ждать инициализации, прежде чем показать ошибку вместо
/// вечного сплеша.
const int startupTimeoutSeconds = 20;

/// [startupTimeoutSeconds] как [Duration].
const Duration startupTimeout = Duration(seconds: startupTimeoutSeconds);
