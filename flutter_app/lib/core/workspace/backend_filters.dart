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
}) {
  final List<String> filters = <String>[];

  if (toggles.contains('grayscale')) {
    filters.add('grayscale');
  }
  if (toggles.contains('flip_horizontal')) {
    filters.add('flip:horizontal');
  }
  if (toggles.contains('sharpen')) {
    filters.add('sharpen:2.0');
  }
  if (toggles.contains('ocr')) {
    filters.add('ocr');
  }

  final double brightness = brightnessPercent / 100;
  final double contrast = contrastPercent / 100;
  if ((brightness - 1).abs() > 0.001 || (contrast - 1).abs() > 0.001) {
    filters.add(
      'brightness_contrast:${_formatNumber(brightness)},${_formatNumber(contrast)}',
    );
  }

  if (blurRadius > 0.01) {
    filters.add('blur:${_formatNumber(blurRadius)}');
  }

  if (rotationDegrees != 0) {
    filters.add('rotate:$rotationDegrees,true');
  }

  final String normalizedFormat = outputFormat.trim().toLowerCase();
  if (normalizedFormat.isNotEmpty) {
    filters.add('format:$normalizedFormat');
  }

  return filters;
}
