import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/services/document_channel.dart';
import 'package:fusionreflow/data/services/document_picker_service.dart';

const _channel = MethodChannel('app.fusionreflow/documents');

void _handle(Future<Object?>? Function(MethodCall call) handler) {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null),
  );
}

void main() {
  test('pick maps channel result', () async {
    _handle((call) async {
      expect(call.method, DocumentChannel.methodPick);
      return {'uri': 'content://x', 'name': 'a.epub', 'size': 10};
    });
    final file = await const DocumentPickerService().pick();
    expect(file, (uri: 'content://x', name: 'a.epub', size: 10));
  });

  test('pick returns null when the user closes the picker', () async {
    _handle((call) async => null);
    expect(await const DocumentPickerService().pick(), isNull);
  });

  test('pick keeps an unknown size null', () async {
    _handle((call) async => {'uri': 'u', 'name': 'n'});
    expect((await const DocumentPickerService().pick())?.size, isNull);
  });

  test('openFd returns int and rethrows errors', () async {
    _handle((call) async {
      expect(call.arguments, {'uri': 'content://x'});
      return 42;
    });
    expect(await const DocumentPickerService().openFd('content://x'), 42);

    _handle(
      (call) async =>
          throw PlatformException(code: DocumentChannel.errorNoAccess),
    );
    await expectLater(
      const DocumentPickerService().openFd('content://x'),
      throwsA(isA<PlatformException>()),
    );
  });

  test('openFd without a descriptor is an error', () async {
    _handle((call) async => null);
    await expectLater(
      const DocumentPickerService().openFd('u'),
      throwsA(isA<PlatformException>()),
    );
  });
}
