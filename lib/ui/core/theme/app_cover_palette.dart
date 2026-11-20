import 'package:flutter/painting.dart';

/// Цвета обложек-заглушек из макета: белый текст на каждом — контраст ≥ 4.5.
abstract final class AppCoverPalette {
  static const List<Color> colors = [
    Color(0xFF6B1F2A),
    Color(0xFF26457A),
    Color(0xFF3A3F5C),
    Color(0xFF2E5E4E),
    Color(0xFF5B4A8A),
    Color(0xFF7A4A1F),
    Color(0xFF1F5F6B),
    Color(0xFF5A2E6B),
  ];

  /// Цвет книги по первым двум hex-символам [sourceHash]; стабилен между
  /// запусками (в отличие от `hashCode`).
  static Color forBook(String sourceHash) {
    final head = sourceHash.length < 2
        ? sourceHash
        : sourceHash.substring(0, 2);
    return colors[(int.tryParse(head, radix: 16) ?? 0) % colors.length];
  }

  /// Цвет по имени файла: у импортируемой книги хеша ещё нет.
  static Color forName(String fileName) =>
      colors[fileName.codeUnits.fold(0, (a, b) => a + b) % colors.length];
}
