import 'dart:typed_data';

import 'pick_images_io.dart' if (dart.library.html) 'pick_images_web.dart';

class PickedImageData {
  const PickedImageData({
    required this.name,
    required this.bytes,
    required this.sizeBytes,
    this.identifier,
    this.wasOptimized = false,
    this.originalSizeBytes,
  });

  final String name;
  final Uint8List bytes;
  final int sizeBytes;
  final String? identifier;
  final bool wasOptimized;
  final int? originalSizeBytes;
}

const int kMaxBatchUploadBytes = 8 * 1024 * 1024;
const int kMaxSingleImageUploadBytes = 3 * 1024 * 1024;

Future<List<PickedImageData>> pickImages() {
  return pickImagesImpl();
}
