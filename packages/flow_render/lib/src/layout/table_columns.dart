import 'dart:math' as math;

/// Widths of table columns that fill [available].
///
/// [content] is the widest one-line content of each column, [minimum] the
/// longest word of it. Columns are proportional to the content but never
/// narrower than their longest word; if the words do not fit, the columns are
/// equal.
List<double> tableColumnWidths({
  required List<double> content,
  required List<double> minimum,
  required double available,
}) {
  final count = content.length;
  if (count == 0) return const [];
  final equal = List.filled(count, available / count);
  final minSum = minimum.fold<double>(0, (a, b) => a + b);
  if (minSum >= available) return equal;
  final weights = [
    for (var i = 0; i < count; i++)
      math.max<double>(0, content[i] - minimum[i]),
  ];
  final weightSum = weights.fold<double>(0, (a, b) => a + b);
  if (weightSum <= 0) {
    // Nothing wider than its longest word: share the spare room equally.
    final extra = (available - minSum) / count;
    return [for (final m in minimum) m + extra];
  }
  final extra = available - minSum;
  return [
    for (var i = 0; i < count; i++) minimum[i] + extra * weights[i] / weightSum,
  ];
}
