import 'package:fusionreflow/config/app_constants.dart';
import 'package:fusionreflow/config/no_retry.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_startup.g.dart';

/// Готовность приложения: мост Rust инициализирован, хранилище книг открыто
/// (база открыта, уборка сирот прошла). Ошибки не глотаются.
@Riverpod(keepAlive: true, retry: noRetry)
Future<void> appStartup(Ref ref) async {
  final rust = ref.read(rustCoreServiceProvider);
  final books = ref.read(bookRepositoryProvider);
  await (() async {
    await rust.init();
    await books.watchAll().first;
  })().timeout(startupTimeout);
}
