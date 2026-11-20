// freezed: у именованных фабрик имя типа обязательно.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';

part 'import_state.freezed.dart';

/// Состояние импорта одной книги.
@freezed
sealed class ImportState with _$ImportState {
  const factory ImportState.idle() = ImportIdle;
  const factory ImportState.running({
    required ImportSource source,
    int? done,
    int? total,
  }) = ImportRunning;
  const factory ImportState.failed({
    required ImportSource source,
    required ImportFailure failure,
  }) = ImportFailedState;

  /// View открывает книгу и зовёт `acknowledge`.
  const factory ImportState.added({required String bookId}) = ImportAdded;
}
