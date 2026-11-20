import 'dart:async';

import 'package:fusionreflow/data/repositories/import_repository.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';

/// [ImportRepository] a test drives by hand through [current].
class FakeImportRepository implements ImportRepository {
  /// Creates the fake; [picked] is what [pick] returns.
  new({this.picked});

  /// Result of [pick].
  ImportSource? picked;

  /// Number of [pick] calls.
  int pickCalls = 0;

  /// Sources passed to [convert].
  final List<ImportSource> converted = [];

  /// Number of [cancel] calls.
  int cancelCalls = 0;

  /// Updates of the latest [convert]; the test adds events and closes it.
  late StreamController<ImportUpdate> current;

  /// Thrown by [pick] when set.
  Object? pickError;

  /// When set, [pick] waits for it (the system picker is open).
  Completer<ImportSource?>? pickGate;

  /// Thrown by [convert] when set.
  Object? convertError;

  @override
  Future<ImportSource?> pick() {
    pickCalls++;
    final error = pickError;
    if (error != null) return Future.error(error);
    return pickGate?.future ?? Future.value(picked);
  }

  @override
  Stream<ImportUpdate> convert(ImportSource source) {
    converted.add(source);
    final error = convertError;
    // ignore: only_throw_errors (tests throw Errors and Exceptions alike)
    if (error != null) throw error;
    current = StreamController<ImportUpdate>();
    return current.stream;
  }

  @override
  Future<void> cancel() async => cancelCalls++;
}
