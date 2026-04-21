import 'dart:typed_data';

class UploadFileItem {
  const UploadFileItem({
    required this.id,
    required this.name,
    required this.sizeLabel,
    required this.sizeBytes,
    required this.bytes,
  });

  final String id;
  final String name;
  final String sizeLabel;
  final int sizeBytes;
  final Uint8List bytes;
}
