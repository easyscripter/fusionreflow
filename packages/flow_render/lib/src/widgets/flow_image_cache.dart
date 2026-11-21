import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flow_render/src/layout/flow_page.dart';

/// Decoded pictures by the identity of their bytes, shared by all pages: a
/// page that is built again (or turned to) finds its pictures ready and does
/// not flicker. Entries live as long as the bytes (the book) do.
abstract final class FlowImageCache {
  static final Expando<ui.Image> _images = Expando<ui.Image>();
  static final Expando<Future<void>> _loading = Expando<Future<void>>();

  /// The decoded picture, or null while it is not ready (or broken).
  static ui.Image? lookup(Uint8List bytes) => _images[bytes];

  /// Decodes [bytes] once; the future never fails.
  static Future<void> load(Uint8List bytes) =>
      _loading[bytes] ??= _decode(bytes);

  static Future<void> _decode(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      _images[bytes] = frame.image;
    } on Exception {
      // A picture that cannot be decoded stays empty.
    }
  }

  /// Bytes of the pictures [page] draws.
  static Iterable<Uint8List> picturesOf(FlowPage page) sync* {
    for (final item in page.items) {
      switch (item) {
        case FlowPictureItem(:final bytes, :final broken) when !broken:
          yield bytes;
        case FlowLineItem(:final inlineImages):
          for (final inline in inlineImages) {
            yield inline.bytes;
          }
        default:
      }
    }
  }

  /// Starts decoding the pictures of [page] (for pages that are not shown
  /// yet).
  static Future<void> precache(FlowPage page) =>
      Future.wait(picturesOf(page).map(load));
}
