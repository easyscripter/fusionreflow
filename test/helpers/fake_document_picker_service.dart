import 'package:fusionreflow/data/services/document_picker_service.dart';

/// [DocumentPickerService] without a channel.
class FakeDocumentPickerService extends DocumentPickerService {
  /// Creates the fake.
  new({this.picked, this.openFdError});

  /// Result of [pick].
  ({String uri, String name, int? size})? picked;

  /// Thrown by [openFd] when set.
  Exception? openFdError;

  /// URIs passed to [openFd].
  final List<String> opened = [];

  @override
  Future<({String uri, String name, int? size})?> pick() async => picked;

  @override
  Future<int> openFd(String uri) async {
    opened.add(uri);
    final error = openFdError;
    if (error != null) throw error;
    return 42;
  }
}
