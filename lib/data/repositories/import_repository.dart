import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:fusionreflow/data/services/bridge_import_event.dart';
import 'package:fusionreflow/data/services/document_picker_service.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import_repository.g.dart';

/// Выбор файла и конвертация его в книгу.
abstract interface class ImportRepository {
  /// Системный выбор файла; null — выбор закрыт без файла (или уже открыт).
  /// Другие сбои канала выбора пробрасываются.
  Future<ImportSource?> pick();

  /// Конвертирует [source]: ноль или больше progress, затем ровно одно
  /// converted или failed, и поток закрывается. format == null → сразу
  /// failed(unsupportedFormat), мост не вызывается. openFd бросил →
  /// failed(noAccess).
  Stream<ImportUpdate> convert(ImportSource source);

  /// Отменяет текущую конвертацию. Если Started ещё не пришёл, отмена
  /// запоминается и уходит в мост сразу после Started. Без текущей
  /// конвертации ничего не делает.
  Future<void> cancel();
}

/// [ImportRepository] поверх канала выбора файлов и Rust-моста.
class BridgeImportRepository implements ImportRepository {
  /// Creates the repository.
  new({required this._picker, required this._rust});

  final DocumentPickerService _picker;
  final RustCoreService _rust;

  bool _running = false;
  bool _cancelRequested = false;
  int? _jobId;

  @override
  Future<ImportSource?> pick() async {
    final ({String uri, String name, int? size})? file;
    try {
      file = await _picker.pick();
    } on PlatformException catch (e) {
      // Выбор уже открыт (двойной тап): это не сбой, ничего не показываем.
      if (e.code == 'busy') return null;
      rethrow;
    }
    if (file == null) return null;
    return ImportSource(
      uri: file.uri,
      name: file.name,
      format: bookFormatOfFileName(file.name),
      sizeBytes: file.size,
    );
  }

  @override
  Stream<ImportUpdate> convert(ImportSource source) async* {
    final format = source.format;
    if (format == null) {
      yield const ImportUpdate.failed(ImportFailure.unsupportedFormat);
      return;
    }
    _running = true; // cancel() во время openFd тоже должен сработать
    _cancelRequested = false;
    _jobId = null;
    final int fd;
    try {
      fd = await _picker.openFd(source.uri);
    } on PlatformException {
      _running = false;
      yield const ImportUpdate.failed(ImportFailure.noAccess);
      return;
    } on Object {
      _running = false;
      yield const ImportUpdate.failed(ImportFailure.unreadable);
      return;
    }
    try {
      // Мост принимает fd сразу: между openFd и importBook нет кода, который
      // может бросить.
      await for (final event in _rust.importBook(fd, format)) {
        switch (event) {
          case BridgeImportStarted(:final jobId):
            _jobId = jobId;
            if (_cancelRequested) unawaited(_rust.cancelImport(jobId));
          case BridgeImportProgress(:final done, :final total):
            yield ImportUpdate.progress(done: done, total: total);
          case BridgeImportDone(:final bytes):
            yield ImportUpdate.converted(bytes);
            return;
          case BridgeImportFailed(:final failure):
            yield ImportUpdate.failed(failure);
            return;
        }
      }
      // Поток закрылся без финального события — не оставляем `running`.
      yield const ImportUpdate.failed(ImportFailure.unreadable);
    } on Object {
      yield const ImportUpdate.failed(ImportFailure.unreadable);
    } finally {
      _running = false;
      _jobId = null;
    }
  }

  @override
  Future<void> cancel() async {
    if (!_running) return;
    _cancelRequested = true;
    final id = _jobId;
    if (id != null) await _rust.cancelImport(id);
  }
}

/// Provides the [ImportRepository].
@Riverpod(keepAlive: true)
ImportRepository importRepository(Ref ref) => BridgeImportRepository(
  picker: ref.watch(documentPickerServiceProvider),
  rust: ref.watch(rustCoreServiceProvider),
);
