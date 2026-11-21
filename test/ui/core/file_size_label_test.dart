import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/file_size_label.dart';

void main() {
  test('formats megabytes', () async {
    final ru = await AppLocalizations.delegate.load(const Locale('ru'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));

    expect(fileSizeLabel(ru, 1887437), '1,8 МБ');
    expect(fileSizeLabel(en, 1887437), '1.8 MB');
  });
}
