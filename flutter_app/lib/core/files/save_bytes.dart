import 'save_bytes_io.dart' if (dart.library.html) 'save_bytes_web.dart';

abstract class SavedFile {
  String get location;
}

Future<SavedFile> saveBytes({
  required String suggestedName,
  required List<int> bytes,
  required String mimeType,
}) {
  return saveBytesImpl(
    suggestedName: suggestedName,
    bytes: bytes,
    mimeType: mimeType,
  );
}
