import 'dart:typed_data';

import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:fusionreflow/src/rust/api/book.dart';

/// Bytes that [FakeRustCoreService.bookMeta] rejects like a corrupt book.
final Uint8List badBookBytes = Uint8List.fromList([0xFF]);

/// Bridge-free [RustCoreService]: bytes `[n]` describe book `n`
/// (`title 'T$n'`, `sourceHash 'h$n'`); [badBookBytes] throw a `FormatError`.
class FakeRustCoreService implements RustCoreService {
  /// Creates the fake; [log] (if given) receives `rust.init` on every [init].
  new({this.log, this.initError});

  /// Shared call journal of a test (see `app_startup_test`).
  final List<String>? log;

  /// Thrown by [init] when set.
  final Exception? initError;

  /// Number of [init] calls.
  int initCalls = 0;

  /// Texts passed to [hyphenate].
  final List<String> hyphenated = [];

  @override
  Future<void> init() async {
    initCalls++;
    log?.add('rust.init');
    final error = initError;
    if (error != null) throw error;
  }

  @override
  String hyphenate(String text) {
    hyphenated.add(text);
    return 'hyphenated:$text';
  }

  @override
  Future<BookMeta> bookMeta(Uint8List bytes) async {
    final n = bytes.first;
    if (n == 0xFF) throw const FormatError.corrupt('bad bytes');
    return BookMeta(
      title: 'T$n',
      authors: ['A$n'],
      sourceHash: 'h$n',
      converterVersion: 'test',
    );
  }
}
