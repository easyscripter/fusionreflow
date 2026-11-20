import 'dart:typed_data';

import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/data/repositories/import_repository.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import_view_model.g.dart';

/// Импорт одной книги; не прерывается при смене вкладки (keepAlive).
@Riverpod(keepAlive: true)
class ImportViewModel extends _$ImportViewModel {
  bool _cancelRequested = false;

  @override
  ImportState build() => const ImportState.idle();

  /// Выбор файла → конвертация → добавление в библиотеку. В `running` ничего
  /// не делает: одновременно идёт один импорт.
  Future<void> pickAndImport() async {
    if (state is ImportRunning) return;
    final source = await ref.read(importRepositoryProvider).pick();
    if (source != null) await _run(source);
  }

  /// Отмена в `running`; итог — `failed(cancelled)`, книга не добавляется.
  Future<void> cancel() async {
    if (state is! ImportRunning || _cancelRequested) return;
    _cancelRequested = true;
    await ref.read(importRepositoryProvider).cancel();
  }

  /// Из `failed`: тот же файл, новый дескриптор.
  Future<void> retry() async {
    final current = state;
    if (current is ImportFailedState) await _run(current.source);
  }

  /// `failed` → `idle`.
  void dismiss() {
    if (state is ImportFailedState) state = const ImportState.idle();
  }

  /// `added` → `idle`.
  void acknowledge() {
    if (state is ImportAdded) state = const ImportState.idle();
  }

  Future<void> _run(ImportSource source) async {
    _cancelRequested = false;
    state = ImportState.running(source: source);
    await for (final update
        in ref.read(importRepositoryProvider).convert(source)) {
      switch (update) {
        case ImportProgress(:final done, :final total):
          if (!_cancelRequested) {
            state = ImportState.running(
              source: source,
              done: done,
              total: total,
            );
          }
        case ImportConverted(:final bytes):
          // Отмена главнее результата (гонка с завершением в Rust).
          state = _cancelRequested
              ? _failed(source, ImportFailure.cancelled)
              : await _add(source, bytes);
        case ImportFailed(:final failure):
          state = _failed(source, failure);
      }
    }
    // Поток закрылся без финального события — не зависаем в `running`.
    if (state is ImportRunning) {
      state = _failed(source, ImportFailure.unreadable);
    }
  }

  Future<ImportState> _add(ImportSource source, Uint8List bytes) async {
    final format = source.format;
    if (format == null) return _failed(source, ImportFailure.unsupportedFormat);
    try {
      final book = await ref.read(bookRepositoryProvider).add(bytes, format);
      return ImportState.added(bookId: book.id);
    } on Object {
      // Нечитаемая книга (BookFormatException) и ошибка записи — одна карточка.
      return _failed(source, ImportFailure.unreadable);
    }
  }

  ImportState _failed(ImportSource source, ImportFailure failure) =>
      ImportState.failed(source: source, failure: failure);
}
