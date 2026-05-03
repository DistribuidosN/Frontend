import 'dart:convert';

enum ResizeMode { scale, dimensions }

class FilterPipelineConfig {
  const FilterPipelineConfig({
    required this.grayscaleEnabled,
    required this.grayscaleIntensity,
    required this.resizeEnabled,
    required this.resizeMode,
    required this.resizeWidth,
    required this.resizeHeight,
    required this.resizeScale,
    required this.pixelateEnabled,
    required this.pixelateBlockSize,
    required this.sepiaEnabled,
    required this.sepiaIntensity,
    required this.colorTintEnabled,
    required this.colorTintRed,
    required this.colorTintGreen,
    required this.colorTintBlue,
    required this.colorTintIntensity,
    required this.posterizeEnabled,
    required this.posterizeBits,
    required this.cropEnabled,
    required this.cropLeft,
    required this.cropUpper,
    required this.cropRight,
    required this.cropLower,
    required this.rotateEnabled,
    required this.rotateAngle,
    required this.rotateExpand,
    required this.rotateFillColor,
    required this.flipEnabled,
    required this.flipDirection,
    required this.blurEnabled,
    required this.blurRadius,
    required this.sharpenEnabled,
    required this.sharpenFactor,
    required this.brightnessContrastEnabled,
    required this.brightness,
    required this.contrast,
    required this.watermarkEnabled,
    required this.watermarkText,
    required this.watermarkOpacity,
    required this.watermarkSize,
    required this.watermarkAngle,
    required this.watermarkColor,
    required this.ocrEnabled,
    required this.ocrLang,
    required this.ocrPsm,
    required this.ocrThreshold,
    required this.inferenceEnabled,
    required this.formatEnabled,
    required this.outputFormat,
  });

  final bool grayscaleEnabled;
  final double grayscaleIntensity;
  final bool resizeEnabled;
  final ResizeMode resizeMode;
  final String resizeWidth;
  final String resizeHeight;
  final String resizeScale;
  final bool pixelateEnabled;
  final int pixelateBlockSize;
  final bool sepiaEnabled;
  final double sepiaIntensity;
  final bool colorTintEnabled;
  final int colorTintRed;
  final int colorTintGreen;
  final int colorTintBlue;
  final double colorTintIntensity;
  final bool posterizeEnabled;
  final int posterizeBits;
  final bool cropEnabled;
  final String cropLeft;
  final String cropUpper;
  final String cropRight;
  final String cropLower;
  final bool rotateEnabled;
  final double rotateAngle;
  final bool rotateExpand;
  final String rotateFillColor;
  final bool flipEnabled;
  final String flipDirection;
  final bool blurEnabled;
  final double blurRadius;
  final bool sharpenEnabled;
  final double sharpenFactor;
  final bool brightnessContrastEnabled;
  final double brightness;
  final double contrast;
  final bool watermarkEnabled;
  final String watermarkText;
  final int watermarkOpacity;
  final int watermarkSize;
  final double watermarkAngle;
  final String watermarkColor;
  final bool ocrEnabled;
  final String ocrLang;
  final String ocrPsm;
  final int ocrThreshold;
  final bool inferenceEnabled;
  final bool formatEnabled;
  final String outputFormat;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

double? _parseDouble(String value) {
  final String normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }
  return double.tryParse(normalized);
}

int? _parseInt(String value) {
  final String normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }
  return int.tryParse(normalized);
}

void _addFilter(
  List<String> filters,
  String operation, [
  Map<String, dynamic>? params,
]) {
  filters.add(
    jsonEncode(<String, dynamic>{
      'name': operation,
      if (params != null && params.isNotEmpty) 'params': jsonEncode(params),
    }),
  );
}

List<String> buildBackendFilters(FilterPipelineConfig config) {
  final List<String> filters = <String>[];

  if (config.cropEnabled) {
    final double? left = _parseDouble(config.cropLeft);
    final double? upper = _parseDouble(config.cropUpper);
    final double? right = _parseDouble(config.cropRight);
    final double? lower = _parseDouble(config.cropLower);
    if (left != null && upper != null && right != null && lower != null) {
      _addFilter(filters, 'crop', <String, dynamic>{
        'left': left,
        'upper': upper,
        'right': right,
        'lower': lower,
      });
    }
  }

  if (config.resizeEnabled) {
    if (config.resizeMode == ResizeMode.scale) {
      final double? scale = _parseDouble(config.resizeScale);
      if (scale != null && scale > 0) {
        _addFilter(filters, 'resize', <String, dynamic>{'scale': scale});
      }
    } else {
      final int? width = _parseInt(config.resizeWidth);
      final int? height = _parseInt(config.resizeHeight);
      if (width != null && height != null && width > 0 && height > 0) {
        _addFilter(filters, 'resize', <String, dynamic>{
          'width': width,
          'height': height,
        });
      }
    }
  }

  if (config.rotateEnabled) {
    final Map<String, dynamic> params = <String, dynamic>{
      'angle': double.parse(_formatNumber(config.rotateAngle)),
      'expand': config.rotateExpand,
    };
    final String fillColor = config.rotateFillColor.trim();
    if (fillColor.isNotEmpty) {
      params['fill_color'] = fillColor;
    }
    _addFilter(filters, 'rotate', params);
  }

  if (config.flipEnabled) {
    _addFilter(filters, 'flip', <String, dynamic>{
      'direction': config.flipDirection,
    });
  }

  if (config.grayscaleEnabled) {
    _addFilter(filters, 'grayscale', <String, dynamic>{
      'intensity': double.parse(_formatNumber(config.grayscaleIntensity)),
    });
  }

  if (config.sepiaEnabled) {
    _addFilter(filters, 'sepia', <String, dynamic>{
      'intensity': double.parse(_formatNumber(config.sepiaIntensity)),
    });
  }

  if (config.posterizeEnabled) {
    _addFilter(filters, 'posterize', <String, dynamic>{
      'bits': config.posterizeBits,
    });
  }

  if (config.pixelateEnabled) {
    _addFilter(filters, 'pixelate', <String, dynamic>{
      'block_size': config.pixelateBlockSize,
    });
  }

  if (config.colorTintEnabled) {
    _addFilter(filters, 'color_tint', <String, dynamic>{
      'r': config.colorTintRed,
      'g': config.colorTintGreen,
      'b': config.colorTintBlue,
      'intensity': double.parse(_formatNumber(config.colorTintIntensity)),
    });
  }

  if (config.brightnessContrastEnabled) {
    _addFilter(filters, 'brightness_contrast', <String, dynamic>{
      'brightness': double.parse(_formatNumber(config.brightness)),
      'contrast': double.parse(_formatNumber(config.contrast)),
    });
  }

  if (config.blurEnabled) {
    _addFilter(filters, 'blur', <String, dynamic>{
      'radius': double.parse(_formatNumber(config.blurRadius)),
    });
  }

  if (config.sharpenEnabled) {
    _addFilter(filters, 'sharpen', <String, dynamic>{
      'factor': double.parse(_formatNumber(config.sharpenFactor)),
    });
  }

  if (config.watermarkEnabled) {
    _addFilter(filters, 'watermark_text', <String, dynamic>{
      'text': config.watermarkText.trim().isEmpty
          ? 'A2WS NODE'
          : config.watermarkText.trim(),
      'opacity': config.watermarkOpacity,
      'size': config.watermarkSize,
      'angle': double.parse(_formatNumber(config.watermarkAngle)),
      'color': config.watermarkColor,
    });
  }

  if (config.ocrEnabled) {
    _addFilter(filters, 'ocr', <String, dynamic>{
      'lang': config.ocrLang.trim().isEmpty ? 'eng+spa' : config.ocrLang.trim(),
      'psm': config.ocrPsm.trim().isEmpty ? '11' : config.ocrPsm.trim(),
      'threshold': config.ocrThreshold,
    });
  }

  if (config.inferenceEnabled) {
    _addFilter(filters, 'inference');
  }

  if (config.formatEnabled) {
    final String normalized = config.outputFormat.trim().toLowerCase();
    if (normalized.isNotEmpty) {
      _addFilter(filters, 'format', <String, dynamic>{
        'extension': normalized,
      });
    }
  }

  return filters;
}
