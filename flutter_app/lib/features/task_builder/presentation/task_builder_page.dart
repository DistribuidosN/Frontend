import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/backend_filters.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class TaskBuilderPage extends StatefulWidget {
  const TaskBuilderPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  State<TaskBuilderPage> createState() => _TaskBuilderPageState();
}

class _TaskBuilderPageState extends State<TaskBuilderPage> {
  static const List<String> _supportedOutputFormats = <String>[
    'JPG',
    'PNG',
    'WEBP',
    'BMP',
    'GIF',
    'TIFF',
    'ICO',
  ];

  final Set<String> _transforms = <String>{};
  double _brightness = 100;
  double _contrast = 100;
  double _blur = 0;
  double _quality = 85;
  int _rotation = 0;
  String _format = 'JPG';
  bool _preserveMetadata = false;
  bool _autoOptimize = true;
  bool _stripProfile = false;
  bool _isSubmitting = false;

  static const List<_TransformOption> _quickTransforms = <_TransformOption>[
    _TransformOption(label: 'Grayscale', value: 'grayscale'),
    _TransformOption(label: 'Flip Horizontal', value: 'flip_horizontal'),
    _TransformOption(label: 'Sharpen', value: 'sharpen'),
    _TransformOption(label: 'Extract Text (OCR)', value: 'ocr'),
  ];

  Future<void> _startProcessing() async {
    final workspace = WorkspaceScope.of(context);
    workspace.setSelectedFilters(
      buildBackendFilters(
        toggles: _transforms,
        brightnessPercent: _brightness,
        contrastPercent: _contrast,
        blurRadius: _blur,
        rotationDegrees: _rotation,
        outputFormat: _format,
        quality: _quality,
        preserveMetadata: _preserveMetadata,
        stripProfile: _stripProfile,
        autoOptimize: _autoOptimize,
      ),
    );

    setState(() => _isSubmitting = true);
    try {
      await workspace.submitBatch();
      if (!mounted) {
        return;
      }
      widget.onNavigate(AppPage.progress);
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
    final int fileCount = WorkspaceScope.of(context).selectedFiles.length;
    final double previewScale = _transforms.contains('flip_horizontal')
        ? -1
        : 1;
    final bool grayscale = _transforms.contains('grayscale');
    final bool ocrEnabled = _transforms.contains('ocr');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Task Builder',
                    style: AppTheme.displayStyle(context, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure transformations with a clearer preview and more deliberate controls.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(onPressed: () {}, child: const Text('Save Preset')),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: _isSubmitting ? null : _startProcessing,
              child: Text(_isSubmitting ? 'Submitting...' : 'Start Processing'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1200;

            final Widget previewPanel = AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.8,
                      color: AppTheme.slate,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Before and after',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Before',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppTheme.canvasSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 54,
                        color: AppTheme.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'After',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 180,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        AppTheme.canvasSoft,
                        AppTheme.sand,
                        (_brightness / 200).clamp(0, 1),
                      )!,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppTheme.navy.withValues(
                            alpha: (_blur / 100).clamp(0, 0.1),
                          ),
                          blurRadius: 20 + _blur,
                          spreadRadius: -18,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 220),
                        turns: _rotation / 360,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(
                            previewScale,
                            1,
                            1,
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: 54,
                            color: grayscale
                                ? AppTheme.slate
                                : AppTheme.ink.withValues(
                                    alpha: (_contrast / 200).clamp(0.35, 1),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.canvasSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Preset impact',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ocrEnabled
                              ? 'OCR is enabled for this batch, so the pipeline will also try to extract text from the selected images.'
                              : 'This configuration keeps contrast crisp, adds controlled brightness and avoids over-processing the batch.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final Widget transformPanel = AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: AppTheme.ink,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Transformations',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Transforms',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _quickTransforms.map((_TransformOption transform) {
                      return TogglePill(
                        label: transform.label,
                        selected: _transforms.contains(transform.value),
                        onTap: () {
                          setState(() {
                            if (_transforms.contains(transform.value)) {
                              _transforms.remove(transform.value);
                            } else {
                              _transforms.add(transform.value);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  RangeField(
                    label: 'Brightness',
                    value: _brightness,
                    min: 0,
                    max: 200,
                    suffix: '%',
                    onChanged: (double value) =>
                        setState(() => _brightness = value),
                  ),
                  RangeField(
                    label: 'Contrast',
                    value: _contrast,
                    min: 0,
                    max: 200,
                    suffix: '%',
                    onChanged: (double value) =>
                        setState(() => _contrast = value),
                  ),
                  RangeField(
                    label: 'Blur',
                    value: _blur,
                    min: 0,
                    max: 20,
                    suffix: 'px',
                    onChanged: (double value) => setState(() => _blur = value),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Text(
                        'Rotation',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const Spacer(),
                      Text(
                        '$_rotation deg',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <int>[0, 90, 180, 270].map((int deg) {
                      return TogglePill(
                        label: '$deg deg',
                        selected: _rotation == deg,
                        onTap: () => setState(() => _rotation = deg),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Text('Resize', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: const <Widget>[
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Width',
                            hintText: '1920',
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height',
                            hintText: '1080',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            final Widget outputPanel = AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.download_outlined,
                        size: 18,
                        color: AppTheme.ink,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Output Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Output Format',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _supportedOutputFormats.map((String format) {
                      return TogglePill(
                        label: format,
                        selected: _format == format,
                        onTap: () => setState(() => _format = format),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  RangeField(
                    label: 'Quality',
                    value: _quality,
                    min: 1,
                    max: 100,
                    suffix: '%',
                    onChanged: (double value) =>
                        setState(() => _quality = value),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Advanced Options',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    label: 'Preserve metadata',
                    value: _preserveMetadata,
                    onChanged: (bool value) =>
                        setState(() => _preserveMetadata = value),
                  ),
                  _SwitchTile(
                    label: 'Auto-optimize',
                    value: _autoOptimize,
                    onChanged: (bool value) =>
                        setState(() => _autoOptimize = value),
                  ),
                  _SwitchTile(
                    label: 'Strip color profile',
                    value: _stripProfile,
                    onChanged: (bool value) =>
                        setState(() => _stripProfile = value),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.canvasSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Batch Processing',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'These settings will be applied to all $fileCount images in the current request.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  previewPanel,
                  const SizedBox(height: 16),
                  transformPanel,
                  const SizedBox(height: 16),
                  outputPanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: previewPanel),
                const SizedBox(width: 16),
                Expanded(child: transformPanel),
                const SizedBox(width: 16),
                Expanded(child: outputPanel),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TransformOption {
  const _TransformOption({required this.label, required this.value});

  final String label;
  final String value;
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
