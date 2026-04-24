import 'dart:typed_data';

import 'pick_images_io.dart' if (dart.library.html) 'pick_images_web.dart';

const List<String> kSupportedUploadExtensions = <String>[
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'bmp',
  'tif',
  'tiff',
  'ico',
  'zip',
  'tar',
  'gz',
  'tgz',
];

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

bool isOptimizableImageName(String name) {
  final int dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) {
    return false;
  }
  switch (name.substring(dot + 1).toLowerCase()) {
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
    case 'bmp':
    case 'tif':
    case 'tiff':
    case 'ico':
      return true;
    default:
      return false;
  }
}

Future<List<PickedImageData>> pickImages() {
  return pickImagesImpl();
}
