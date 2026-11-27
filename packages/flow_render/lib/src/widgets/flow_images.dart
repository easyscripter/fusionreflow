import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flow_render/src/layout/flow_page.dart';
import 'package:flutter/foundation.dart';

/// Decoded pictures of the pages in use (the shown one and its neighbours),
/// by the identity of their bytes. A picture is decoded no wider than it is
/// drawn and is disposed once no page in use has it, so memory does not grow
/// with the book. Listeners are told when a picture becomes ready.
class FlowImages extends ChangeNotifier {
  final _images = Map<Uint8List, ({ui.Image image, int width})>.identity();
  final _loading = Map<Uint8List, Future<void>>.identity();

  /// Bytes in use and the widest size they are drawn at, px.
  Map<Uint8List, int> _wanted = Map.identity();
  bool _disposed = false;

  /// The decoded picture, or null while it is not ready (or broken).
  ui.Image? operator [](Uint8List bytes) => _images[bytes]?.image;

  /// Makes [pages] the ones in use, at [pixelRatio] pixels per dp. Completes
  /// when their pictures are ready; never fails.
  Future<void> show(Iterable<FlowPage> pages, double pixelRatio) {
    _wanted = _picturesOf(pages, pixelRatio);
    _images.removeWhere((bytes, entry) {
      if (_wanted.containsKey(bytes)) return false;
      entry.image.dispose();
      return true;
    });
    return Future.wait([for (final bytes in _wanted.keys) _ensure(bytes)]);
  }

  Future<void> _ensure(Uint8List bytes) async {
    // Another decode of these bytes may be running: wait, then look again.
    await _loading[bytes];
    final width = _wanted[bytes];
    if (width == null || (_images[bytes]?.width ?? 0) >= width) return;
    final loading = _decode(bytes, width);
    _loading[bytes] = loading;
    await loading;
  }

  Future<void> _decode(Uint8List bytes, int width) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: width,
        allowUpscaling: false,
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (_disposed || !_wanted.containsKey(bytes)) {
        frame.image.dispose();
        return;
      }
      _images[bytes]?.image.dispose();
      _images[bytes] = (image: frame.image, width: width);
      notifyListeners();
    } on Exception {
      // A picture that cannot be decoded stays empty.
    }
  }

  static Map<Uint8List, int> _picturesOf(
    Iterable<FlowPage> pages,
    double pixelRatio,
  ) {
    final wanted = Map<Uint8List, int>.identity();
    void add(Uint8List bytes, double width) {
      final pixels = math.max(1, (width * pixelRatio).ceil());
      wanted[bytes] = math.max(wanted[bytes] ?? 0, pixels);
    }

    void addInline(List<FlowInlineImage> images) {
      for (final inline in images) {
        add(inline.bytes, inline.box.width);
      }
    }

    for (final item in pages.expand((p) => p.items)) {
      switch (item) {
        case FlowPictureItem(:final bytes, :final broken, :final rect)
            when !broken:
          add(bytes, rect.width);
        case FlowLineItem(:final inlineImages):
          addInline(inlineImages);
        case FlowRowItem(:final cells):
          for (final cell in cells) {
            addInline(cell.inlineImages);
          }
        case FlowPictureItem() || FlowLabelItem() || FlowRuleItem():
      }
    }
    return wanted;
  }

  @override
  void dispose() {
    _disposed = true;
    _wanted = Map.identity();
    for (final entry in _images.values) {
      entry.image.dispose();
    }
    _images.clear();
    super.dispose();
  }
}
