import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_coverage.dart';

void main() {
  group('isInScope', () {
    test('accepts logic layers', () {
      expect(isInScope('lib/domain/models/book.dart'), isTrue);
      expect(isInScope('lib/data/repositories/text_repository.dart'), isTrue);
      expect(isInScope('lib/utils/strings.dart'), isTrue);
      expect(
        isInScope('lib/ui/spikes/view_models/hyphen_spike_view_model.dart'),
        isTrue,
      );
    });

    test('rejects widgets, generated code and other folders', () {
      expect(isInScope('lib/ui/home/widgets/home_screen.dart'), isFalse);
      expect(
        isInScope('lib/data/repositories/text_repository.g.dart'),
        isFalse,
      );
      expect(isInScope('lib/domain/models/book.freezed.dart'), isFalse);
      expect(isInScope('lib/src/rust/api/text.dart'), isFalse);
      expect(isInScope('lib/l10n/app_localizations.dart'), isFalse);
      expect(isInScope('test/data/text_repository_test.dart'), isFalse);
    });

    test('accepts package logic but not package widgets', () {
      expect(isInScope('packages/flow_render/lib/src/layout/a.dart'), isTrue);
      expect(isInScope('packages/flow_render/lib/src/model/a.dart'), isTrue);
      expect(
        isInScope('packages/flow_render/lib/src/widgets/flow_page_view.dart'),
        isFalse,
      );
      expect(isInScope('packages/flow_render/lib/flow_render.dart'), isFalse);
      expect(isInScope('packages/flow_render/test/a_test.dart'), isFalse);
    });

    test('normalises Windows separators', () {
      expect(isInScope(r'lib\data\services\rust_core_service.dart'), isTrue);
    });
  });

  group('parseLcov', () {
    test('reads found and hit lines per file', () {
      const lcov = r'''
SF:lib\data\a.dart
DA:1,1
DA:2,0
LF:2
LH:1
end_of_record
SF:lib/data/b.dart
LF:4
LH:4
end_of_record
''';
      final files = parseLcov(lcov);
      expect(files.keys, ['lib/data/a.dart', 'lib/data/b.dart']);
      expect(files['lib/data/a.dart'], (found: 2, hit: 1));
      expect(files['lib/data/b.dart'], (found: 4, hit: 4));
    });

    test('returns an empty map for empty input', () {
      expect(parseLcov(''), isEmpty);
    });
  });

  group('evaluate', () {
    test('passes at exactly the threshold', () {
      final result = evaluate({
        'lib/data/a.dart': (found: 20, hit: 17),
        'lib/ui/home/widgets/home_screen.dart': (found: 100, hit: 0),
      });
      expect(result.found, 20);
      expect(result.hit, 17);
      expect(result.percent, 85.0);
      expect(result.passed, isTrue);
    });

    test('fails below the threshold', () {
      final result = evaluate({'lib/data/a.dart': (found: 20, hit: 16)});
      expect(result.passed, isFalse);
    });

    test('fails when nothing in scope was measured', () {
      final result = evaluate({
        'lib/ui/home/widgets/home_screen.dart': (found: 10, hit: 10),
      });
      expect(result.found, 0);
      expect(result.passed, isFalse);
    });
  });

  group('withPrefix', () {
    test('moves package paths to the repository root', () {
      expect(
        withPrefix({'lib/src/a.dart': (found: 2, hit: 1)}, 'packages/p/'),
        {'packages/p/lib/src/a.dart': (found: 2, hit: 1)},
      );
    });
  });

  group('importsFor', () {
    test('lists package files by the package prefix', () {
      final imports = importsFor('flow_render', [
        'lib/src/layout/a.dart',
        'lib/src/widgets/w.dart',
        'lib/flow_render.dart',
      ], prefix: 'packages/flow_render/');
      expect(imports, ["import 'package:flow_render/src/layout/a.dart';"]);
    });

    test('lists in-scope files as package imports, sorted', () {
      final imports = importsFor('fusionreflow', [
        'lib/utils/b.dart',
        'lib/data/a.dart',
        'lib/data/a.g.dart',
        'lib/ui/home/widgets/home_screen.dart',
      ]);
      expect(imports, [
        "import 'package:fusionreflow/data/a.dart';",
        "import 'package:fusionreflow/utils/b.dart';",
      ]);
    });
  });
}
