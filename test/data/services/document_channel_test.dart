import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/services/document_channel.dart';

const _kotlin =
    'android/app/src/main/kotlin/app/fusionreflow/fusionreflow/'
    'DocumentChannel.kt';

void main() {
  // The channel contract lives in Dart and in Kotlin; this keeps the copies
  // equal, so a renamed code cannot silently break one side.
  test('Kotlin channel constants match the Dart ones', () {
    final source = File(_kotlin).readAsStringSync();
    final kotlin = {
      for (final m in RegExp(r'const val (\w+) = "([^"]*)"').allMatches(source))
        m[1]!: m[2]!,
    };

    expect(kotlin, {
      'CHANNEL': DocumentChannel.name,
      'METHOD_PICK': DocumentChannel.methodPick,
      'METHOD_OPEN_FD': DocumentChannel.methodOpenFd,
      'ARG_URI': DocumentChannel.argUri,
      'KEY_URI': DocumentChannel.keyUri,
      'KEY_NAME': DocumentChannel.keyName,
      'KEY_SIZE': DocumentChannel.keySize,
      'ERROR_BUSY': DocumentChannel.errorBusy,
      'ERROR_PICK_FAILED': DocumentChannel.errorPickFailed,
      'ERROR_NO_FILE': DocumentChannel.errorNoFile,
      'ERROR_NO_ACCESS': DocumentChannel.errorNoAccess,
      'ERROR_BAD_ARGS': DocumentChannel.errorBadArgs,
    });
  });
}
