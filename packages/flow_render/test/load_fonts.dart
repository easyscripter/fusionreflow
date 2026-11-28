import 'dart:io';

import 'package:flutter/services.dart';

Future<void> _load(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final path in files) {
    final data = Uint8List.fromList(File(path).readAsBytesSync());
    loader.addFont(Future.value(ByteData.sublistView(data)));
  }
  await loader.load();
}

/// Loads the app fonts (from the app's `assets/`) so goldens show real glyphs.
Future<void> loadFonts() async {
  const root = '../../assets/fonts';
  await _load('Literata', [
    '$root/literata/Literata-Regular.ttf',
    '$root/literata/Literata-Italic.ttf',
  ]);
  await _load('JetBrainsMono', [
    '$root/jetbrains_mono/JetBrainsMono-Regular.ttf',
  ]);
}
