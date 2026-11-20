import 'dart:typed_data';

import 'package:fusionreflow/domain/models/import_update.dart';

/// Событие импорта от Rust-моста без типов `lib/src/rust/**`: так
/// репозитории не зависят от сгенерированного кода.
sealed class BridgeImportEvent {
  const new();
}

/// Задача запущена; [jobId] нужен для отмены.
class BridgeImportStarted extends BridgeImportEvent {
  const new(this.jobId);
  final int jobId;
}

/// Ход конвертации.
class BridgeImportProgress extends BridgeImportEvent {
  const new({required this.done, required this.total});
  final int done;
  final int total;
}

/// Готовая книга (CBOR).
class BridgeImportDone extends BridgeImportEvent {
  const new(this.bytes);
  final Uint8List bytes;
}

/// Мост отказал; причина уже переведена для экрана.
class BridgeImportFailed extends BridgeImportEvent {
  const new(this.failure);
  final ImportFailure failure;
}
