import 'dart:typed_data';
import 'dart:ui' as ui;

/// Pixel size of an encoded image without decoding it; null if the bytes are
/// empty or not an image the engine knows.
Future<ui.Size?> readImageSize(Uint8List bytes) async {
  if (bytes.isEmpty) return null;
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  try {
    buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    if (descriptor.width <= 0 || descriptor.height <= 0) return null;
    return ui.Size(descriptor.width.toDouble(), descriptor.height.toDouble());
  } on Exception {
    return null;
  } finally {
    descriptor?.dispose();
    buffer?.dispose();
  }
}
