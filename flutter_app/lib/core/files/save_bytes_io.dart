import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'save_bytes.dart';

class IoSavedFile implements SavedFile {
  const IoSavedFile(this.location);

  @override
  final String location;
}

Future<SavedFile> saveBytesImpl({
  required String suggestedName,
  required List<int> bytes,
  required String mimeType,
}) async {
  final String? path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save file',
    fileName: suggestedName,
  );

  if (path == null || path.isEmpty) {
    throw StateError('Save cancelled.');
  }

  final File file = File(path);
  await file.writeAsBytes(bytes, flush: true);
  return IoSavedFile(file.path);
}
