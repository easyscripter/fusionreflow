import 'package:flutter/widgets.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

/// Language name for a book's tag ("ru" → "Русский" in a Russian UI); null when
/// there is no tag. An unknown tag comes back as is.
String? languageLabel(BuildContext context, String? tag) {
  final normalized = normalizeLanguageTag(tag);
  if (normalized == null) return null;
  final names = LocaleNames.of(context);
  final name =
      names?.nameOf(normalized) ?? names?.nameOf(normalized.split('_').first);
  if (name == null || name.isEmpty) return tag?.trim();
  // CLDR spells language names in lower case ("русский").
  return name[0].toUpperCase() + name.substring(1);
}

/// `EN-us` → `en_US`; an empty tag → null.
String? normalizeLanguageTag(String? tag) {
  final parts = (tag ?? '').trim().replaceAll('-', '_').split('_');
  if (parts.first.isEmpty) return null;
  return [
    parts.first.toLowerCase(),
    for (final part in parts.skip(1))
      if (part.length == 2) part.toUpperCase() else part,
  ].join('_');
}
