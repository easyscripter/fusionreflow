// Architecture rules from AGENTS.md (section 2.2, section 5), checked on the
// source tree so that a violation fails `flutter test` and CI.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Hand-written Dart files under lib/ (generated code is excluded).
List<File> _sources() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !_isGenerated(f.path))
        .toList();

bool _isGenerated(String path) {
  final p = path.replaceAll(r'\', '/');
  return p.endsWith('.g.dart') ||
      p.endsWith('.freezed.dart') ||
      p.contains('lib/src/rust/') ||
      p.contains('lib/l10n/app_localizations');
}

String _rel(File f) => f.path.replaceAll(r'\', '/');

final _importRe = RegExp(
  "^import 'package:fusionreflow/([^']+)'",
  multiLine: true,
);

/// Package imports of [file] relative to lib/, e.g. `data/services/x.dart`.
List<String> _imports(File file) => _importRe
    .allMatches(file.readAsStringSync())
    .map((m) => m.group(1)!)
    .toList();

/// Layer of a lib-relative path: ui, domain, data, utils, ... or the file.
String _layer(String libPath) => libPath.split('/').first;

void main() {
  final sources = _sources();

  test('there are sources to check', () {
    expect(sources, isNotEmpty);
  });

  test(
    'layer import directions: domain/utils -> nothing above, data -/-> ui',
    () {
      const forbidden = {
        'domain': {'ui', 'data', 'config', 'routing'},
        'utils': {'ui', 'data', 'domain', 'config', 'routing'},
        'data': {'ui', 'routing'},
      };
      final violations = <String>[];
      for (final file in sources) {
        final from = _layer(_rel(file).replaceFirst('lib/', ''));
        for (final target in _imports(file)) {
          if (forbidden[from]?.contains(_layer(target)) ?? false) {
            violations.add('${_rel(file)} imports $target');
          }
        }
      }
      expect(violations, isEmpty);
    },
  );

  test('generated Rust bridge is used only from data/services', () {
    final violations = sources
        .where((f) => !_rel(f).startsWith('lib/data/services/'))
        .where((f) => !_rel(f).endsWith('lib/main.dart'))
        .where((f) => _imports(f).any((i) => i.startsWith('src/rust/')))
        .map(_rel)
        .toList();
    expect(violations, isEmpty);
  });

  test('view models do not import Flutter widgets or services', () {
    final violations = <String>[];
    for (final file in sources.where(
      (f) => _rel(f).contains('/view_models/'),
    )) {
      final text = file.readAsStringSync();
      if (text.contains("import 'package:flutter/")) {
        violations.add('${_rel(file)} imports Flutter');
      }
      for (final target in _imports(file)) {
        if (target.startsWith('data/services/')) {
          violations.add('${_rel(file)} imports $target');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('view models do not import the render package widgets', () {
    final violations = [
      for (final file in sources.where(
        (f) => _rel(f).contains('/view_models/'),
      ))
        if (file.readAsStringSync().contains(
          'package:flow_render/widgets.dart',
        ))
          _rel(file),
    ];
    expect(violations, isEmpty);
  });

  test('flow_render does not depend on the app or Riverpod', () {
    final files = Directory('packages/flow_render/lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    expect(files, isNotEmpty);
    final violations = [
      for (final file in files)
        for (final banned in const [
          'package:fusionreflow/',
          'package:flutter_riverpod/',
          'package:riverpod',
          'package:hooks_riverpod/',
        ])
          if (file.readAsStringSync().contains(banned))
            '${_rel(file)} imports $banned',
    ];
    expect(violations, isEmpty);
    final pubspec = File('packages/flow_render/pubspec.yaml')
        .readAsStringSync();
    expect(pubspec, isNot(contains('riverpod')));
    expect(pubspec, isNot(contains('fusionreflow')));
  });

  test('one public widget per file, named after the file', () {
    final widgetRe = RegExp(
      r'^class (\w+) extends (?:StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget)',
      multiLine: true,
    );
    final violations = <String>[];
    for (final file in sources) {
      final names = widgetRe
          .allMatches(file.readAsStringSync())
          .map((m) => m.group(1)!)
          .where((n) => !n.startsWith('_'))
          .toList();
      if (names.length > 1) {
        violations.add('${_rel(file)} has ${names.join(', ')}');
      }
      for (final name in names) {
        final expected = '${_snake(name)}.dart';
        if (!_rel(file).endsWith('/$expected')) {
          violations.add('${_rel(file)}: $name should live in $expected');
        }
      }
    }
    expect(violations, isEmpty);
  });
}

String _snake(String camel) => camel
    .replaceAllMapped(RegExp('(?<=[a-z0-9])([A-Z])'), (m) => '_${m[1]}')
    .toLowerCase();
