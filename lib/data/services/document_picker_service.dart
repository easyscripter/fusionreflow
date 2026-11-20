import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'document_picker_service.g.dart';

/// Системный выбор файла и дескрипторы выбранных файлов (канал на Kotlin).
class DocumentPickerService {
  /// Creates the service; the channel is injectable for tests.
  const new({
    this._channel = const MethodChannel('app.fusionreflow/documents'),
  });

  final MethodChannel _channel;

  /// Системный выбор файла; null — пользователь закрыл выбор.
  Future<({String uri, String name, int? size})?> pick() async {
    final result = await _channel.invokeMapMethod<String, Object?>('pick');
    if (result == null) return null;
    return (
      uri: result['uri']! as String,
      name: result['name']! as String,
      size: (result['size'] as num?)?.toInt(),
    );
  }

  /// Новый дескриптор для чтения [uri]; владение переходит к вызывающему.
  /// Бросает PlatformException, если файла нет или доступ отозван.
  Future<int> openFd(String uri) async {
    final fd = await _channel.invokeMethod<int>('openFd', {'uri': uri});
    if (fd == null) throw PlatformException(code: 'no_fd');
    return fd;
  }
}

/// Provides the [DocumentPickerService].
@Riverpod(keepAlive: true)
DocumentPickerService documentPickerService(Ref ref) =>
    const DocumentPickerService();
