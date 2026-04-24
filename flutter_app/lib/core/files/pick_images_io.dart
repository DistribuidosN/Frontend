import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'pick_images.dart';

Future<List<PickedImageData>> pickImagesImpl() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.image,
    withData: true,
    withReadStream: true,
    lockParentWindow: true,
  );

  if (result == null || result.files.isEmpty) {
    return const <PickedImageData>[];
  }

  final List<PickedImageData> images = <PickedImageData>[];
  for (final PlatformFile file in result.files) {
    final Uint8List? bytes = await _resolveFileBytes(file);
    if (bytes == null || bytes.isEmpty) {
      continue;
    }

    images.add(
        PickedImageData(
          name: file.name,
          bytes: bytes,
          sizeBytes: file.size > 0 ? file.size : bytes.length,
          identifier: file.identifier,
          wasOptimized: false,
          originalSizeBytes: file.size > 0 ? file.size : bytes.length,
        ),
      );
  }

  return images;
}

Future<Uint8List?> _resolveFileBytes(PlatformFile file) async {
  final Uint8List? directBytes = file.bytes;
  if (directBytes != null && directBytes.isNotEmpty) {
    return directBytes;
  }

  final Stream<List<int>>? stream = file.readStream;
  if (stream != null) {
    final BytesBuilder builder = BytesBuilder(copy: false);
    await for (final List<int> chunk in stream) {
      if (chunk.isNotEmpty) {
        builder.add(chunk);
      }
    }
    final Uint8List streamedBytes = builder.takeBytes();
    if (streamedBytes.isNotEmpty) {
      return streamedBytes;
    }
  }

  try {
    final Uint8List xFileBytes = await file.xFile.readAsBytes();
    if (xFileBytes.isNotEmpty) {
      return xFileBytes;
    }
  } catch (_) {
    return null;
  }

  return null;
}
