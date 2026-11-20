import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/config/no_retry.dart';

void main() {
  test('noRetry never schedules a retry', () {
    expect(noRetry(0, Exception('x')), isNull);
    expect(noRetry(5, StateError('y')), isNull);
  });
}
