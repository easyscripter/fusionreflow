import 'dart:typed_data';

import 'package:fusionreflow/src/rust/api/book.dart' as rust_book;
import 'package:fusionreflow/src/rust/api/text.dart' as rust_text;
import 'package:fusionreflow/src/rust/frb_generated.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rust_core_service.g.dart';

/// Thin, stateless wrapper over the Rust core bridge.
///
/// The only place in the app that talks to the generated bridge code
/// (`lib/src/rust/**`); repositories depend on this service instead.
class RustCoreService {
  /// Creates the service.
  const new();

  /// Loads the native library; safe to call again (retry after a failed
  /// start, tests that already initialised the bridge).
  Future<void> init() async {
    if (RustLib.instance.initialized) return;
    await RustLib.init();
  }

  /// Inserts soft hyphens (U+00AD) at allowed break points of ru/en words.
  String hyphenate(String text) => rust_text.hyphenate(text: text);

  /// Reads the catalog data (title, authors, hashes) of CBOR-encoded [bytes].
  ///
  /// Runs on the bridge's thread pool, so a large book does not block the UI.
  /// Bridge errors (`FormatError`) are not caught here.
  Future<rust_book.BookMeta> bookMeta(Uint8List bytes) =>
      rust_book.bookMeta(bytes: bytes);
}

/// Provides the [RustCoreService].
@Riverpod(keepAlive: true)
RustCoreService rustCoreService(Ref ref) => const RustCoreService();
