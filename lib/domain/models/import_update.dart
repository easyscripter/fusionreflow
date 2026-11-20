// freezed: у именованных фабрик имя типа обязательно.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_update.freezed.dart';

/// Что происходит с импортом, без типов моста.
@freezed
sealed class ImportUpdate with _$ImportUpdate {
  const factory ImportUpdate.progress({required int done, required int total}) =
      ImportProgress;
  const factory ImportUpdate.converted(Uint8List bytes) = ImportConverted;
  const factory ImportUpdate.failed(ImportFailure failure) = ImportFailed;
}

/// Причина неудачи; у каждой своя карточка по макету `states`.
enum ImportFailure {
  pdfNotYet,
  unsupportedFormat,
  unreadable,
  noAccess,
  cancelled,
}
