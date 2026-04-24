// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'save_bytes.dart';

class WebSavedFile implements SavedFile {
  const WebSavedFile(this.location);

  @override
  final String location;
}

Future<SavedFile> saveBytesImpl({
  required String suggestedName,
  required List<int> bytes,
  required String mimeType,
}) async {
  final html.Blob blob = html.Blob(<Object>[Uint8List.fromList(bytes)], mimeType);
  final String url = html.Url.createObjectUrlFromBlob(blob);
  final html.AnchorElement anchor = html.AnchorElement(href: url)
    ..download = suggestedName
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return const WebSavedFile('browser-download');
}
