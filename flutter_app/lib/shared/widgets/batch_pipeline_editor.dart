import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/backend_filters.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class BatchPipelineEditor extends StatefulWidget {
  const BatchPipelineEditor({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onStarted,
    this.onApplied,
    this.onClose,
    this.applyButtonLabel = 'Apply Filters',
    this.startButtonLabel = 'Start Processing',
    this.showApplyButton = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onStarted;
  final VoidCallback? onApplied;
  final VoidCallback? onClose;
  final String applyButtonLabel;
  final String startButtonLabel;
  final bool showApplyButton;

  @override
  State<BatchPipelineEditor> createState() => _BatchPipelineEditorState();
}

class _BatchPipelineEditorState extends State<BatchPipelineEditor> {
  static const List<String> _supportedOutputFormats = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
    'tif',
    'ico',
  ];

  static const List<String> _flipDirections = <String>[
    'horizontal',
    'vertical',
    'both',
  ];

  static const List<String> _watermarkColors = <String>[
    'white',
    'black',
    'red',
    'blue',
  ];

  bool _isSubmitting = false;

  bool _grayscaleEnabled = false;
  double _grayscaleIntensity = 1.0;

  bool _resizeEnabled = false;
  ResizeMode _resizeMode = ResizeMode.scale;
  String _resizeWidth = '';
  String _resizeHeight = '';
  String _resizeScale = '0.50';

  bool _pixelateEnabled = false;
  int _pixelateBlockSize = 10;

  bool _sepiaEnabled = false;
  double _sepiaIntensity = 1.0;

  bool _colorTintEnabled = false;
  int _colorTintRed = 255;
  int _colorTintGreen = 255;
  int _colorTintBlue = 255;
  double _colorTintIntensity = 0.3;

  bool _posterizeEnabled = false;
  int _posterizeBits = 4;

  bool _cropEnabled = false;
  String _cropLeft = '';
  String _cropUpper = '';
  String _cropRight = '';
  String _cropLower = '';

  bool _rotateEnabled = false;
  double _rotateAngle = 0;
  bool _rotateExpand = true;
  String _rotateFillColor = '';

  bool _flipEnabled = false;
  String _flipDirection = 'horizontal';

  bool _blurEnabled = false;
  double _blurRadius = 2.0;

  bool _sharpenEnabled = false;
  double _sharpenFactor = 2.0;

  bool _brightnessContrastEnabled = false;
  double _brightness = 1.0;
  double _contrast = 1.0;

  bool _watermarkEnabled = false;
  String _watermarkText = 'A2WS NODE';
  int _watermarkOpacity = 80;
  int _watermarkSize = 60;
  double _watermarkAngle = 45;
  String _watermarkColor = 'white';

  bool _ocrEnabled = false;
  String _ocrLang = 'eng+spa';
  String _ocrPsm = '11';
  int _ocrThreshold = 170;

  bool _inferenceEnabled = false;

  bool _formatEnabled = true;
  String _outputFormat = 'jpg';

  FilterPipelineConfig get _config => FilterPipelineConfig(
    grayscaleEnabled: _grayscaleEnabled,
    grayscaleIntensity: _grayscaleIntensity,
    resizeEnabled: _resizeEnabled,
    resizeMode: _resizeMode,
    resizeWidth: _resizeWidth,
    resizeHeight: _resizeHeight,
    resizeScale: _resizeScale,
    pixelateEnabled: _pixelateEnabled,
    pixelateBlockSize: _pixelateBlockSize,
    sepiaEnabled: _sepiaEnabled,
    sepiaIntensity: _sepiaIntensity,
    colorTintEnabled: _colorTintEnabled,
    colorTintRed: _colorTintRed,
    colorTintGreen: _colorTintGreen,
    colorTintBlue: _colorTintBlue,
    colorTintIntensity: _colorTintIntensity,
    posterizeEnabled: _posterizeEnabled,
    posterizeBits: _posterizeBits,
    cropEnabled: _cropEnabled,
    cropLeft: _cropLeft,
    cropUpper: _cropUpper,
    cropRight: _cropRight,
    cropLower: _cropLower,
    rotateEnabled: _rotateEnabled,
    rotateAngle: _rotateAngle,
    rotateExpand: _rotateExpand,
    rotateFillColor: _rotateFillColor,
    flipEnabled: _flipEnabled,
    flipDirection: _flipDirection,
    blurEnabled: _blurEnabled,
    blurRadius: _blurRadius,
    sharpenEnabled: _sharpenEnabled,
    sharpenFactor: _sharpenFactor,
    brightnessContrastEnabled: _brightnessContrastEnabled,
    brightness: _brightness,
    contrast: _contrast,
    watermarkEnabled: _watermarkEnabled,
    watermarkText: _watermarkText,
    watermarkOpacity: _watermarkOpacity,
    watermarkSize: _watermarkSize,
    watermarkAngle: _watermarkAngle,
    watermarkColor: _watermarkColor,
    ocrEnabled: _ocrEnabled,
    ocrLang: _ocrLang,
    ocrPsm: _ocrPsm,
    ocrThreshold: _ocrThreshold,
    inferenceEnabled: _inferenceEnabled,
    formatEnabled: _formatEnabled,
    outputFormat: _outputFormat,
  );

  List<String> get _activeOperations {
    final List<String> active = <String>[];
    if (_cropEnabled) active.add('crop');
    if (_resizeEnabled) active.add('resize');
    if (_rotateEnabled) active.add('rotate');
    if (_flipEnabled) active.add('flip');
    if (_grayscaleEnabled) active.add('grayscale');
    if (_sepiaEnabled) active.add('sepia');
    if (_posterizeEnabled) active.add('posterize');
    if (_pixelateEnabled) active.add('pixelate');
    if (_colorTintEnabled) active.add('color_tint');
    if (_brightnessContrastEnabled) active.add('brightness_contrast');
    if (_blurEnabled) active.add('blur');
    if (_sharpenEnabled) active.add('sharpen');
    if (_watermarkEnabled) active.add('watermark_text');
    if (_ocrEnabled) active.add('ocr');
    if (_inferenceEnabled) active.add('inference');
    if (_formatEnabled) active.add('format');
    return active;
  }

  Future<void> _applyFilters() async {
    final workspace = WorkspaceScope.of(context);
    workspace.setSelectedFilters(buildBackendFilters(_config));
    widget.onApplied?.call();
  }

  Future<void> _start() async {
    final workspace = WorkspaceScope.of(context);
    workspace.setSelectedFilters(buildBackendFilters(_config));
    setState(() => _isSubmitting = true);
    try {
      await workspace.submitBatch();
      if (!mounted) {
        return;
      }
      widget.onStarted();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final int fileCount = workspace.selectedFiles.length;
    final bool hasFiles = fileCount > 0;
    final Uint8List? previewBytes = hasFiles
        ? workspace.selectedFiles.first.bytes
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.title, style: AppTheme.displayStyle(context, size: 30)),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            if (widget.onClose != null)
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close_rounded),
              ),
          ],
        ),
        const SizedBox(height: 18),
        AppSurface(
          child: Wrap(
            spacing: 24,
            runSpacing: 14,
            children: <Widget>[
              MiniLabel(label: 'Files', value: '$fileCount'),
              MiniLabel(label: 'Operations', value: '${_activeOperations.length}'),
              MiniLabel(
                label: 'OCR',
                value: _ocrEnabled ? 'Enabled' : 'Disabled',
              ),
              MiniLabel(
                label: 'Output',
                value: _formatEnabled ? _outputFormat.toUpperCase() : 'Original',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1180;

            final Widget editorColumn = Column(
              children: <Widget>[
                _OperationCard(
                  title: 'Geometry',
                  description:
                      'Crop, resize, rotate and flip before the tone and analysis stages.',
                  child: Column(
                    children: <Widget>[
                      _ToggleSection(
                        title: 'Crop',
                        value: _cropEnabled,
                        onChanged: (bool value) =>
                            setState(() => _cropEnabled = value),
                        child: AdaptiveGrid(
                          minItemWidth: 160,
                          childAspectRatio: 2.2,
                          children: <Widget>[
                            _TextEntryField(
                              label: 'Left',
                              value: _cropLeft,
                              hintText: '0',
                              onChanged: (String value) =>
                                  setState(() => _cropLeft = value),
                            ),
                            _TextEntryField(
                              label: 'Upper',
                              value: _cropUpper,
                              hintText: '0',
                              onChanged: (String value) =>
                                  setState(() => _cropUpper = value),
                            ),
                            _TextEntryField(
                              label: 'Right',
                              value: _cropRight,
                              hintText: '1024',
                              onChanged: (String value) =>
                                  setState(() => _cropRight = value),
                            ),
                            _TextEntryField(
                              label: 'Lower',
                              value: _cropLower,
                              hintText: '768',
                              onChanged: (String value) =>
                                  setState(() => _cropLower = value),
                            ),
                          ],
                        ),
                      ),
                      _ToggleSection(
                        title: 'Resize',
                        value: _resizeEnabled,
                        onChanged: (bool value) =>
                            setState(() => _resizeEnabled = value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ResizeMode.values.map((ResizeMode mode) {
                                final String label = mode == ResizeMode.scale
                                    ? 'Scale'
                                    : 'Width + Height';
                                return TogglePill(
                                  label: label,
                                  selected: _resizeMode == mode,
                                  onTap: () => setState(() => _resizeMode = mode),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                            if (_resizeMode == ResizeMode.scale)
                              _TextEntryField(
                                label: 'Scale factor',
                                value: _resizeScale,
                                hintText: '0.50',
                                helperText: 'Use 0.25 for thumbnails or 2.0 to double the size.',
                                onChanged: (String value) =>
                                    setState(() => _resizeScale = value),
                              )
                            else
                              AdaptiveGrid(
                                minItemWidth: 180,
                                childAspectRatio: 2.1,
                                children: <Widget>[
                                  _TextEntryField(
                                    label: 'Width',
                                    value: _resizeWidth,
                                    hintText: '1920',
                                    onChanged: (String value) =>
                                        setState(() => _resizeWidth = value),
                                  ),
                                  _TextEntryField(
                                    label: 'Height',
                                    value: _resizeHeight,
                                    hintText: '1080',
                                    onChanged: (String value) =>
                                        setState(() => _resizeHeight = value),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      _ToggleSection(
                        title: 'Rotate',
                        value: _rotateEnabled,
                        onChanged: (bool value) =>
                            setState(() => _rotateEnabled = value),
                        child: Column(
                          children: <Widget>[
                            RangeField(
                              label: 'Angle',
                              value: _rotateAngle,
                              min: -180,
                              max: 180,
                              suffix: ' deg',
                              onChanged: (double value) =>
                                  setState(() => _rotateAngle = value),
                            ),
                            _SwitchTile(
                              label: 'Expand canvas to fit rotation',
                              value: _rotateExpand,
                              onChanged: (bool value) =>
                                  setState(() => _rotateExpand = value),
                            ),
                            _TextEntryField(
                              label: 'Fill color',
                              value: _rotateFillColor,
                              hintText: 'black',
                              helperText:
                                  'Optional. Used to paint the empty corners after rotation.',
                              onChanged: (String value) =>
                                  setState(() => _rotateFillColor = value),
                            ),
                          ],
                        ),
                      ),
                      _ToggleSection(
                        title: 'Flip',
                        value: _flipEnabled,
                        onChanged: (bool value) =>
                            setState(() => _flipEnabled = value),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _flipDirections.map((String direction) {
                            return TogglePill(
                              label: direction,
                              selected: _flipDirection == direction,
                              onTap: () =>
                                  setState(() => _flipDirection = direction),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _OperationCard(
                  title: 'Color And Tone',
                  description:
                      'Expose every backend control for grayscale, sepia, tint, posterize and brightness.',
                  child: Column(
                    children: <Widget>[
                      _ToggleSection(
                        title: 'Grayscale',
                        value: _grayscaleEnabled,
                        onChanged: (bool value) =>
                            setState(() => _grayscaleEnabled = value),
                        child: RangeField(
                          label: 'Intensity',
                          value: _grayscaleIntensity * 100,
                          min: 0,
                          max: 100,
                          suffix: '%',
                          onChanged: (double value) =>
                              setState(() => _grayscaleIntensity = value / 100),
                        ),
                      ),
                      _ToggleSection(
                        title: 'Sepia',
                        value: _sepiaEnabled,
                        onChanged: (bool value) =>
                            setState(() => _sepiaEnabled = value),
                        child: RangeField(
                          label: 'Intensity',
                          value: _sepiaIntensity * 100,
                          min: 0,
                          max: 100,
                          suffix: '%',
                          onChanged: (double value) =>
                              setState(() => _sepiaIntensity = value / 100),
                        ),
                      ),
                      _ToggleSection(
                        title: 'Posterize',
                        value: _posterizeEnabled,
                        onChanged: (bool value) =>
                            setState(() => _posterizeEnabled = value),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List<int>.generate(8, (int index) => index + 1)
                              .map((int bits) {
                            return TogglePill(
                              label: '$bits bits',
                              selected: _posterizeBits == bits,
                              onTap: () => setState(() => _posterizeBits = bits),
                            );
                          }).toList(),
                        ),
                      ),
                      _ToggleSection(
                        title: 'Color tint',
                        value: _colorTintEnabled,
                        onChanged: (bool value) =>
                            setState(() => _colorTintEnabled = value),
                        child: Column(
                          children: <Widget>[
                            RangeField(
                              label: 'Red',
                              value: _colorTintRed.toDouble(),
                              min: 0,
                              max: 255,
                              suffix: '',
                              onChanged: (double value) =>
                                  setState(() => _colorTintRed = value.round()),
                            ),
                            RangeField(
                              label: 'Green',
                              value: _colorTintGreen.toDouble(),
                              min: 0,
                              max: 255,
                              suffix: '',
                              onChanged: (double value) => setState(
                                () => _colorTintGreen = value.round(),
                              ),
                            ),
                            RangeField(
                              label: 'Blue',
                              value: _colorTintBlue.toDouble(),
                              min: 0,
                              max: 255,
                              suffix: '',
                              onChanged: (double value) =>
                                  setState(() => _colorTintBlue = value.round()),
                            ),
                            RangeField(
                              label: 'Overlay intensity',
                              value: _colorTintIntensity * 100,
                              min: 0,
                              max: 100,
                              suffix: '%',
                              onChanged: (double value) => setState(
                                () => _colorTintIntensity = value / 100,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ToggleSection(
                        title: 'Brightness + Contrast',
                        value: _brightnessContrastEnabled,
                        onChanged: (bool value) => setState(
                          () => _brightnessContrastEnabled = value,
                        ),
                        child: Column(
                          children: <Widget>[
                            RangeField(
                              label: 'Brightness',
                              value: _brightness * 100,
                              min: 0,
                              max: 200,
                              suffix: '%',
                              onChanged: (double value) =>
                                  setState(() => _brightness = value / 100),
                            ),
                            RangeField(
                              label: 'Contrast',
                              value: _contrast * 100,
                              min: 0,
                              max: 200,
                              suffix: '%',
                              onChanged: (double value) =>
                                  setState(() => _contrast = value / 100),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _OperationCard(
                  title: 'Effects And Analysis',
                  description:
                      'Pixelation, blur, sharpening, watermarking, OCR and inference remain fully configurable.',
                  child: Column(
                    children: <Widget>[
                      _ToggleSection(
                        title: 'Pixelate',
                        value: _pixelateEnabled,
                        onChanged: (bool value) =>
                            setState(() => _pixelateEnabled = value),
                        child: RangeField(
                          label: 'Block size',
                          value: _pixelateBlockSize.toDouble(),
                          min: 1,
                          max: 50,
                          suffix: ' px',
                          onChanged: (double value) => setState(
                            () => _pixelateBlockSize = value.round(),
                          ),
                        ),
                      ),
                      _ToggleSection(
                        title: 'Blur',
                        value: _blurEnabled,
                        onChanged: (bool value) =>
                            setState(() => _blurEnabled = value),
                        child: RangeField(
                          label: 'Radius',
                          value: _blurRadius,
                          min: 0,
                          max: 20,
                          suffix: ' px',
                          onChanged: (double value) =>
                              setState(() => _blurRadius = value),
                        ),
                      ),
                      _ToggleSection(
                        title: 'Sharpen',
                        value: _sharpenEnabled,
                        onChanged: (bool value) =>
                            setState(() => _sharpenEnabled = value),
                        child: RangeField(
                          label: 'Factor',
                          value: _sharpenFactor * 10,
                          min: 0,
                          max: 50,
                          suffix: '',
                          onChanged: (double value) =>
                              setState(() => _sharpenFactor = value / 10),
                        ),
                      ),
                      _ToggleSection(
                        title: 'Watermark text',
                        value: _watermarkEnabled,
                        onChanged: (bool value) =>
                            setState(() => _watermarkEnabled = value),
                        child: Column(
                          children: <Widget>[
                            _TextEntryField(
                              label: 'Text',
                              value: _watermarkText,
                              hintText: 'CONFIDENCIAL',
                              onChanged: (String value) =>
                                  setState(() => _watermarkText = value),
                            ),
                            RangeField(
                              label: 'Opacity',
                              value: _watermarkOpacity.toDouble(),
                              min: 0,
                              max: 255,
                              suffix: '',
                              onChanged: (double value) => setState(
                                () => _watermarkOpacity = value.round(),
                              ),
                            ),
                            RangeField(
                              label: 'Size',
                              value: _watermarkSize.toDouble(),
                              min: 10,
                              max: 120,
                              suffix: ' px',
                              onChanged: (double value) =>
                                  setState(() => _watermarkSize = value.round()),
                            ),
                            RangeField(
                              label: 'Angle',
                              value: _watermarkAngle,
                              min: -180,
                              max: 180,
                              suffix: ' deg',
                              onChanged: (double value) =>
                                  setState(() => _watermarkAngle = value),
                            ),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _watermarkColors.map((String color) {
                                return TogglePill(
                                  label: color,
                                  selected: _watermarkColor == color,
                                  onTap: () =>
                                      setState(() => _watermarkColor = color),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      _ToggleSection(
                        title: 'OCR',
                        value: _ocrEnabled,
                        onChanged: (bool value) =>
                            setState(() => _ocrEnabled = value),
                        child: Column(
                          children: <Widget>[
                            AdaptiveGrid(
                              minItemWidth: 180,
                              childAspectRatio: 2.2,
                              children: <Widget>[
                                _TextEntryField(
                                  label: 'Languages',
                                  value: _ocrLang,
                                  hintText: 'eng+spa',
                                  onChanged: (String value) =>
                                      setState(() => _ocrLang = value),
                                ),
                                _TextEntryField(
                                  label: 'PSM',
                                  value: _ocrPsm,
                                  hintText: '11',
                                  onChanged: (String value) =>
                                      setState(() => _ocrPsm = value),
                                ),
                              ],
                            ),
                            RangeField(
                              label: 'Threshold',
                              value: _ocrThreshold.toDouble(),
                              min: 0,
                              max: 255,
                              suffix: '',
                              onChanged: (double value) =>
                                  setState(() => _ocrThreshold = value.round()),
                            ),
                          ],
                        ),
                      ),
                      _ToggleSection(
                        title: 'Inference',
                        value: _inferenceEnabled,
                        onChanged: (bool value) =>
                            setState(() => _inferenceEnabled = value),
                        child: Text(
                          'Runs the worker image classification pass without extra parameters.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.slate,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final Widget previewColumn = Column(
              children: <Widget>[
                AppSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Preview', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 18),
                      AdaptiveGrid(
                        minItemWidth: 220,
                        childAspectRatio: 1.1,
                        children: <Widget>[
                          _PreviewTile(
                            label: 'Before',
                            previewBytes: previewBytes,
                            grayscale: false,
                            brightness: 1.0,
                            contrast: 1.0,
                            blur: 0,
                            rotation: 0,
                            scaleX: 1,
                            scaleY: 1,
                            tintColor: null,
                          ),
                          _PreviewTile(
                            label: 'After',
                            previewBytes: previewBytes,
                            grayscale: _grayscaleEnabled,
                            brightness: _brightnessContrastEnabled
                                ? _brightness
                                : 1.0,
                            contrast: _brightnessContrastEnabled
                                ? _contrast
                                : 1.0,
                            blur: _blurEnabled ? _blurRadius : 0,
                            rotation: _rotateEnabled ? _rotateAngle : 0,
                            scaleX: _flipEnabled &&
                                    (_flipDirection == 'horizontal' ||
                                        _flipDirection == 'both')
                                ? -1
                                : 1,
                            scaleY: _flipEnabled &&
                                    (_flipDirection == 'vertical' ||
                                        _flipDirection == 'both')
                                ? -1
                                : 1,
                            tintColor: _colorTintEnabled
                                ? Color.fromARGB(
                                    (_colorTintIntensity * 255).round().clamp(
                                      0,
                                      255,
                                    ),
                                    _colorTintRed,
                                    _colorTintGreen,
                                    _colorTintBlue,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'The preview approximates geometry, grayscale, brightness, contrast, blur and tint. Posterize, OCR, watermark, inference and format are executed by the backend worker.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.slate,
                          height: 1.5,
                        ),
                      ),
                      if (_activeOperations.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _activeOperations.map((String operation) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppTheme.outlineVariant),
                              ),
                              child: Text(
                                operation,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: AppTheme.navy),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Output',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      _ToggleSection(
                        title: 'Format conversion',
                        value: _formatEnabled,
                        onChanged: (bool value) =>
                            setState(() => _formatEnabled = value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _supportedOutputFormats.map(
                                (String extension) {
                                  return TogglePill(
                                    label: extension.toUpperCase(),
                                    selected: _outputFormat == extension,
                                    onTap: () => setState(
                                      () => _outputFormat = extension,
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Disable this section if you want to preserve the original extension.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.canvasSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          _ocrEnabled
                              ? 'OCR is enabled. This batch will return transformed images and trigger text extraction in the worker.'
                              : _inferenceEnabled
                              ? 'Inference is enabled. The worker will also compute statistical image classification.'
                              : 'This pipeline will apply exactly the enabled operations in the order defined by the frontend serializer.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.slate, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          if (widget.showApplyButton) ...<Widget>[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: (!hasFiles || _isSubmitting)
                                    ? null
                                    : _applyFilters,
                                child: Text(widget.applyButtonLabel),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: FilledButton(
                              onPressed: (!hasFiles || _isSubmitting)
                                  ? null
                                  : _start,
                              child: Text(
                                !hasFiles
                                    ? 'Select files to continue'
                                    : _isSubmitting
                                    ? 'Submitting...'
                                    : widget.startButtonLabel,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!hasFiles) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          'Preview mode only. Add images first to enable backend processing.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  editorColumn,
                  const SizedBox(height: 16),
                  previewColumn,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 6, child: editorColumn),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: previewColumn),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.slate, height: 1.5),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ToggleSection extends StatelessWidget {
  const _ToggleSection({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.child,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.labelLarge),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
          if (value) ...<Widget>[
            const SizedBox(height: 8),
            child,
          ],
        ],
      ),
    );
  }
}

class _TextEntryField extends StatelessWidget {
  const _TextEntryField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.helperText,
  });

  final String label;
  final String value;
  final String? hintText;
  final String? helperText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
          ),
        ),
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.label,
    required this.previewBytes,
    required this.grayscale,
    required this.brightness,
    required this.contrast,
    required this.blur,
    required this.rotation,
    required this.scaleX,
    required this.scaleY,
    required this.tintColor,
  });

  final String label;
  final Uint8List? previewBytes;
  final bool grayscale;
  final double brightness;
  final double contrast;
  final double blur;
  final double rotation;
  final double scaleX;
  final double scaleY;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.slate,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: Color.lerp(
                AppTheme.canvasSoft,
                AppTheme.sand,
                brightness.clamp(0, 2) / 2,
              )!,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 220),
                turns: rotation / 360,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ColorFiltered(
                        colorFilter: grayscale
                            ? const ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0, 0, 0, 1, 0,
                              ])
                            : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.srcOver,
                              ),
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(
                            sigmaX: blur,
                            sigmaY: blur,
                          ),
                          child: Opacity(
                            opacity: contrast.clamp(0.35, 1.6) / 1.6,
                            child: previewBytes == null
                                ? const Icon(
                                    Icons.image_outlined,
                                    size: 54,
                                    color: AppTheme.onSurfaceVariant,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(
                                      previewBytes!,
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        BuildContext context,
                                        Object error,
                                        StackTrace? stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.broken_image_outlined,
                                          size: 54,
                                          color: AppTheme.onSurfaceVariant,
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (tintColor != null)
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: tintColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.sand,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.slate,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
