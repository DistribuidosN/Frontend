// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'pick_images.dart';

const int _targetMaxDimension = 1600;

Future<List<PickedImageData>> pickImagesImpl() async {
  final html.FileUploadInputElement input = html.FileUploadInputElement()
    ..accept = 'image/*,.zip,.tar,.gz,.tgz'
    ..multiple = true;

  final Completer<List<PickedImageData>> completer =
      Completer<List<PickedImageData>>();

  input.onChange.listen((_) async {
    final List<html.File>? files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) {
        completer.complete(const <PickedImageData>[]);
      }
      return;
    }

    final List<PickedImageData> images = <PickedImageData>[];
    for (final html.File file in files) {
      final PickedImageData? optimized = await _prepareFile(file);
      if (optimized == null) {
        continue;
      }
      images.add(optimized);
    }

    if (!completer.isCompleted) {
      completer.complete(images);
    }
  });

  input.click();
  return completer.future.timeout(
    const Duration(minutes: 2),
    onTimeout: () => const <PickedImageData>[],
  );
}

Future<PickedImageData?> _prepareFile(html.File file) async {
  final Uint8List bytes = await _readFileBytes(file);
  if (bytes.isEmpty) {
    return null;
  }

  if (!isOptimizableImageName(file.name)) {
    return PickedImageData(
      name: file.name,
      bytes: bytes,
      sizeBytes: file.size,
      identifier: file.name,
      originalSizeBytes: file.size,
    );
  }

  final bool needsOptimization =
      file.size > kMaxSingleImageUploadBytes || await _needsResize(file);

  if (!needsOptimization) {
    return PickedImageData(
      name: file.name,
      bytes: bytes,
      sizeBytes: file.size,
      identifier: file.name,
      originalSizeBytes: file.size,
    );
  }

  final _OptimizedImage? optimized = await _compressImage(file);
  if (optimized == null || optimized.bytes.length >= bytes.length) {
    return PickedImageData(
      name: file.name,
      bytes: bytes,
      sizeBytes: file.size,
      identifier: file.name,
      originalSizeBytes: file.size,
    );
  }

  return PickedImageData(
    name: optimized.fileName,
    bytes: optimized.bytes,
    sizeBytes: optimized.bytes.length,
    identifier: file.name,
    wasOptimized: true,
    originalSizeBytes: file.size,
  );
}

Future<bool> _needsResize(html.File file) async {
  final html.ImageElement image = await _loadImage(file);
  return image.naturalWidth > _targetMaxDimension ||
      image.naturalHeight > _targetMaxDimension;
}

Future<_OptimizedImage?> _compressImage(html.File file) async {
  try {
    final html.ImageElement image = await _loadImage(file);
    final double width = image.naturalWidth.toDouble();
    final double height = image.naturalHeight.toDouble();
    final double scale = width > height
        ? (_targetMaxDimension / width).clamp(0, 1)
        : (_targetMaxDimension / height).clamp(0, 1);

    final html.CanvasElement canvas = html.CanvasElement(
      width: (width * scale).round(),
      height: (height * scale).round(),
    );
    canvas.context2D.drawImageScaled(
      image,
      0,
      0,
      canvas.width!.toDouble(),
      canvas.height!.toDouble(),
    );

    for (final double quality in <double>[0.82, 0.72, 0.6, 0.5]) {
      final Uint8List blobBytes = _canvasToJpegBytes(canvas, quality);
      if (blobBytes.isEmpty) {
        continue;
      }
      if (blobBytes.length <= kMaxSingleImageUploadBytes || quality == 0.5) {
        return _OptimizedImage(
          bytes: blobBytes,
          fileName: _toJpgName(file.name),
        );
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}

Future<html.ImageElement> _loadImage(html.File file) {
  final Completer<html.ImageElement> completer = Completer<html.ImageElement>();
  final String objectUrl = html.Url.createObjectUrl(file);
  final html.ImageElement image = html.ImageElement(src: objectUrl);

  image.onLoad.first.then((_) {
    html.Url.revokeObjectUrl(objectUrl);
    completer.complete(image);
  });
  image.onError.first.then((_) {
    html.Url.revokeObjectUrl(objectUrl);
    completer.completeError(StateError('Could not decode image.'));
  });

  return completer.future;
}

Uint8List _canvasToJpegBytes(html.CanvasElement canvas, double quality) {
  final String dataUrl = canvas.toDataUrl('image/jpeg', quality);
  final int commaIndex = dataUrl.indexOf(',');
  if (commaIndex < 0) {
    return Uint8List(0);
  }
  return base64Decode(dataUrl.substring(commaIndex + 1));
}

Future<Uint8List> _readFileBytes(html.File file) {
  final Completer<Uint8List> completer = Completer<Uint8List>();
  final html.FileReader reader = html.FileReader();

  reader.onLoadEnd.listen((_) {
    final Object? result = reader.result;
    if (result is ByteBuffer) {
      completer.complete(result.asUint8List());
      return;
    }
    if (result is Uint8List) {
      completer.complete(result);
      return;
    }
    completer.complete(Uint8List(0));
  });

  reader.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.complete(Uint8List(0));
    }
  });

  reader.readAsArrayBuffer(file);
  return completer.future;
}

String _toJpgName(String name) {
  final int dot = name.lastIndexOf('.');
  if (dot <= 0) {
    return '$name.jpg';
  }
  return '${name.substring(0, dot)}.jpg';
}

class _OptimizedImage {
  const _OptimizedImage({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}
