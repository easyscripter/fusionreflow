import 'package:flutter/services.dart';
import 'package:fusionreflow/data/services/document_channel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'document_picker_service.g.dart';

/// Системный выбор файла и дескрипторы выбранных файлов (канал на Kotlin).
class DocumentPickerService {
  /// Creates the service; the channel is injectable for tests.
  const new({this._channel = const MethodChannel(DocumentChannel.name)});

  final MethodChannel _channel;

  /// Системный выбор файла; null — пользователь закрыл выбор.
  Future<({String uri, String name, int? size})?> pick() async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      DocumentChannel.methodPick,
    );
    if (result == null) return null;
    return (
      uri: result[DocumentChannel.keyUri]! as String,
      name: result[DocumentChannel.keyName]! as String,
      size: (result[DocumentChannel.keySize] as num?)?.toInt(),
    );
  }

  /// Новый дескриптор для чтения [uri]; владение переходит к вызывающему.
  /// Бросает PlatformException, если файла нет или доступ отозван.
  Future<int> openFd(String uri) async {
    final fd = await _channel.invokeMethod<int>(DocumentChannel.methodOpenFd, {
      DocumentChannel.argUri: uri,
    });
    if (fd == null) throw PlatformException(code: DocumentChannel.errorNoFd);
    return fd;
  }
}

/// Provides the [DocumentPickerService].
@Riverpod(keepAlive: true)
DocumentPickerService documentPickerService(Ref ref) =>
    const DocumentPickerService();
