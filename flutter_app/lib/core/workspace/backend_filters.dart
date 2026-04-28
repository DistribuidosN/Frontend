import 'dart:convert';

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

List<String> buildBackendFilters({
  required Set<String> toggles,
  required double brightnessPercent,
  required double contrastPercent,
  required double blurRadius,
  required int rotationDegrees,
  required String outputFormat,
  required double quality,
  required bool preserveMetadata,
  required bool stripProfile,
  required bool autoOptimize,
}) {
  final List<String> filters = <String>[];

  if (toggles.contains('grayscale')) {
    filters.add(jsonEncode({'name': 'grayscale'}));
  }
  if (toggles.contains('flip_horizontal')) {
    filters.add(jsonEncode({'name': 'flip', 'params': jsonEncode({'direction': 'horizontal'})}));
  }
  if (toggles.contains('sharpen')) {
    filters.add(jsonEncode({'name': 'sharpen', 'params': jsonEncode({'amount': 2.0})}));
  }
  if (toggles.contains('ocr')) {
    filters.add(jsonEncode({'name': 'ocr'}));
  }

  final double brightness = brightnessPercent / 100;
  final double contrast = contrastPercent / 100;
  if ((brightness - 1).abs() > 0.001 || (contrast - 1).abs() > 0.001) {
    filters.add(
      jsonEncode({
        'name': 'brightness_contrast',
        'params': jsonEncode({
          'brightness': double.parse(_formatNumber(brightness)),
          'contrast': double.parse(_formatNumber(contrast)),
        })
      }),
    );
  }

  if (blurRadius > 0.01) {
    filters.add(jsonEncode({
      'name': 'blur',
      'params': jsonEncode({'sigma': double.parse(_formatNumber(blurRadius))})
    }));
  }

  if (rotationDegrees != 0) {
    filters.add(jsonEncode({
      'name': 'rotate',
      'params': jsonEncode({'angle': rotationDegrees, 'expand': 'true'})
    }));
  }

  final String normalizedFormat = outputFormat.trim().toLowerCase();
  
  // Always apply convert filter if format is specified
  if (normalizedFormat.isNotEmpty) {
    filters.add(jsonEncode({
      'name': 'convert',
      'params': jsonEncode({
        'format': normalizedFormat,
        // Agregamos quality si es necesario, pero usando la sintaxis de Postman
        if (quality < 100) 'quality': quality.toInt(),
      })
    }));
  }

  return filters;
}
