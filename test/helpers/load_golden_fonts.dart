import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<void> _load(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(Uint8List.fromList(file.readAsBytesSync())),
        ),
      );
    }
  }
  await loader.load();
}

/// Loads the app fonts (and Material icons) so goldens show real glyphs, and
/// hides the debug banner.
Future<void> loadGoldenFonts() async {
  WidgetsApp.debugAllowBannerOverride = false;
  await _load('GolosText', ['assets/fonts/golos_text/GolosText.ttf']);
  await _load('Literata', [
    'assets/fonts/literata/Literata-Regular.ttf',
    'assets/fonts/literata/Literata-Italic.ttf',
  ]);
  await _load('JetBrainsMono', [
    'assets/fonts/jetbrains_mono/JetBrainsMono-Regular.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    await _load('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  }
}
