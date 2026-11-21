// Dart coverage gate (AGENTS.md, section 6).
//
// Layers with logic must have at least 85% line coverage: lib/domain,
// lib/data, lib/ui/**/view_models, lib/utils, and the packages under
// packages/ (lib/src except widgets/). Widgets and generated code are not
// counted.
//
// Usage (from the repository root):
//   dart run tool/check_coverage.dart prepare   # writes the all-files tests
//   flutter test --coverage                     # also in every packages/<name>
//   dart run tool/check_coverage.dart check [--threshold=85]
//
// `flutter test --coverage` reports only files that some test loads, so a
// file nobody tests would silently vanish from the report. `prepare` writes
// `test/all_in_scope_files_test.dart` (git-ignored) that imports every
// in-scope file, so untested files show up with 0% instead.
import 'dart:io';

/// Default minimum line coverage, in percent.
const double defaultThreshold = 85;

/// Package name used for generated imports.
const String packageName = 'fusionreflow';

/// Path of the generated test that loads every in-scope file.
const String allFilesTestPath = 'test/all_in_scope_files_test.dart';

/// Lines found and hit for one file.
typedef FileCoverage = ({int found, int hit});

final RegExp _scope = RegExp(
  '^(?:lib/(?:domain/|data/|utils/|ui/(?:[^/]+/)*view_models/)'
  '|packages/[^/]+/lib/src/(?!widgets/))',
);

/// Whether [path] (relative to the repository root) must be covered.
bool isInScope(String path) {
  final normalized = path.replaceAll(r'\', '/');
  if (normalized.endsWith('.g.dart') || normalized.endsWith('.freezed.dart')) {
    return false;
  }
  return normalized.endsWith('.dart') && _scope.hasMatch(normalized);
}

/// Parses lcov text into found/hit line counts per file (`/` separators).
Map<String, FileCoverage> parseLcov(String lcov) {
  final files = <String, FileCoverage>{};
  String? current;
  var found = 0;
  var hit = 0;
  for (final line in lcov.split('\n').map((l) => l.trim())) {
    if (line.startsWith('SF:')) {
      current = line.substring(3).replaceAll(r'\', '/');
      found = 0;
      hit = 0;
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && current != null) {
      files[current] = (found: found, hit: hit);
      current = null;
    }
  }
  return files;
}

/// Result of checking coverage against a threshold.
class CoverageResult {
  /// Creates a result for [found] executable and [hit] covered lines.
  const new({required this.found, required this.hit, required this.threshold});

  /// Executable lines in scope.
  final int found;

  /// Covered lines in scope.
  final int hit;

  /// Required minimum, in percent.
  final double threshold;

  /// Coverage in percent; 0 when nothing was measured.
  double get percent => found == 0 ? 0 : hit * 100 / found;

  /// Whether something was measured and it meets the threshold.
  bool get passed => found > 0 && percent >= threshold;
}

/// Sums coverage of in-scope files and compares it with [threshold].
CoverageResult evaluate(
  Map<String, FileCoverage> files, {
  double threshold = defaultThreshold,
}) {
  var found = 0;
  var hit = 0;
  for (final entry in files.entries) {
    if (isInScope(entry.key)) {
      found += entry.value.found;
      hit += entry.value.hit;
    }
  }
  return CoverageResult(found: found, hit: hit, threshold: threshold);
}

/// Sorted `import` lines for the in-scope [paths] of package [package].
/// [paths] are relative to the package; [prefix] is where the package lives
/// relative to the repository root (`packages/name/`, empty for the app).
List<String> importsFor(
  String package,
  Iterable<String> paths, {
  String prefix = '',
}) {
  final imports = <String>[
    for (final path in paths)
      if (isInScope('$prefix${path.replaceAll(r'\', '/')}'))
        "import 'package:$package/${path.replaceAll(r'\', '/').substring('lib/'.length)}';",
  ]..sort();
  return imports;
}

/// Maps an lcov path of a package to the repository root.
Map<String, FileCoverage> withPrefix(
  Map<String, FileCoverage> files,
  String prefix,
) => {for (final e in files.entries) '$prefix${e.key}': e.value};

/// The packages under `packages/`: name -> directory.
Map<String, String> _packages() => {
  if (Directory('packages').existsSync())
    for (final dir in Directory('packages').listSync())
      if (dir is Directory && File('${dir.path}/pubspec.yaml').existsSync())
        dir.uri.pathSegments.where((s) => s.isNotEmpty).last: dir.path,
};

List<String> _libFiles(String root) => [
  for (final entity in Directory('$root/lib').listSync(recursive: true))
    if (entity is File)
      entity.path.replaceAll(r'\', '/').substring(root.length + 1),
];

void _writeAllFilesTest(String root, String package, String prefix) {
  final imports = importsFor(package, _libFiles(root), prefix: prefix);
  final body = StringBuffer()
    ..writeln(
      '// GENERATED by tool/check_coverage.dart prepare. Not committed.',
    )
    ..writeln('// ignore_for_file: unused_import')
    ..writeln()
    ..writeln(imports.join('\n'))
    ..writeln()
    ..writeln('void main() {}');
  final path = '$root/$allFilesTestPath';
  File(path).writeAsStringSync(body.toString());
  stdout.writeln('Wrote $path (${imports.length} files).');
}

void _prepare() {
  _writeAllFilesTest('.', packageName, '');
  for (final entry in _packages().entries) {
    _writeAllFilesTest(entry.value, entry.key, 'packages/${entry.key}/');
  }
}

int _check(List<String> args) {
  var threshold = defaultThreshold;
  for (final arg in args) {
    if (arg.startsWith('--threshold=')) {
      threshold = double.parse(arg.substring('--threshold='.length));
    }
  }
  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    stderr.writeln('coverage/lcov.info not found: run flutter test --coverage');
    return 2;
  }
  final files = parseLcov(lcov.readAsStringSync());
  for (final entry in _packages().entries) {
    final report = File('${entry.value}/coverage/lcov.info');
    if (!report.existsSync()) {
      stderr.writeln(
        '${report.path} not found: run flutter test --coverage in '
        '${entry.value}',
      );
      return 2;
    }
    files.addAll(
      withPrefix(
        parseLcov(report.readAsStringSync()),
        'packages/${entry.key}/',
      ),
    );
  }
  final inScope = {
    for (final e in files.entries)
      if (isInScope(e.key)) e.key: e.value,
  };
  for (final entry
      in (inScope.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) {
    final c = entry.value;
    final percent = c.found == 0 ? 100 : c.hit * 100 / c.found;
    stdout.writeln(
      '${percent.toStringAsFixed(1).padLeft(6)}%  '
      '${c.hit}/${c.found}  ${entry.key}',
    );
  }
  final result = evaluate(files, threshold: threshold);
  stdout.writeln(
    'Dart logic layers: ${result.percent.toStringAsFixed(1)}% '
    '(${result.hit}/${result.found} lines), required '
    '${threshold.toStringAsFixed(0)}%.',
  );
  if (!result.passed) {
    stderr.writeln('FAILED: coverage is below the threshold.');
    return 1;
  }
  return 0;
}

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/check_coverage.dart prepare|check');
    exit(64);
  }
  switch (args.first) {
    case 'prepare':
      _prepare();
    case 'check':
      exit(_check(args.skip(1).toList()));
    default:
      stderr.writeln('unknown command: ${args.first}');
      exit(64);
  }
}
