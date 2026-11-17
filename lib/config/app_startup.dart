import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_startup.g.dart';

/// Сколько ждать инициализации, прежде чем показать ошибку вместо вечного
/// сплеша.
const Duration startupTimeout = Duration(seconds: 20);

/// Ошибку запуска не повторяем сами (Riverpod по умолчанию повторяет): её
/// сразу видит человек и решает кнопкой «Повторить».
Duration? _noRetry(int retryCount, Object error) => null;

/// Готовность приложения: мост Rust инициализирован, хранилище книг открыто
/// (база открыта, уборка сирот прошла). Ошибки не глотаются.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<void> appStartup(Ref ref) async {
  final rust = ref.read(rustCoreServiceProvider);
  final books = ref.read(bookRepositoryProvider);
  await (() async {
    await rust.init();
    await books.watchAll().first;
  })().timeout(startupTimeout);
}
