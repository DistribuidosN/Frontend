// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

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
  final String content = base64Encode(bytes);
  final String url = 'data:$mimeType;base64,$content';
  final html.AnchorElement anchor = html.AnchorElement(href: url)
    ..download = suggestedName
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  return const WebSavedFile('browser-download');
}
