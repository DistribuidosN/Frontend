import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/backend_filters.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_file_item.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isPickingFiles = false;

  Future<void> _addFiles() async {
    if (_isPickingFiles) {
      return;
    }

    setState(() => _isPickingFiles = true);
    try {
      final workspace = WorkspaceScope.of(context);
      final bool picked = await workspace.pickFiles();
      if (!mounted) {
        return;
      }
      if (!picked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              workspace.lastSelectionMessage ??
                  'No valid image files were selected.',
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            workspace.lastSelectionMessage ??
                '${workspace.selectedFiles.length} file(s) added to the batch.',
          ),
        ),
      );
      await _openBatchBuilder();
    } finally {
      if (mounted) {
        setState(() => _isPickingFiles = false);
      }
    }
  }

  Future<void> _openBatchBuilder() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return _BatchBuilderSheet(
          onStarted: () {
            if (Navigator.of(modalContext).canPop()) {
              Navigator.of(modalContext).pop();
            }
            widget.onNavigate(AppPage.progress);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final List<UploadFileItem> files = workspace.selectedFiles;
    final double totalSize =
        files.fold<int>(
          0,
          (int sum, UploadFileItem file) => sum + file.sizeBytes,
        ) /
        (1024 * 1024);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PageIntro(
          kicker: 'Primary flow',
          title: 'Start a processing batch',
          description:
              'Upload images or archives, configure filters immediately, and launch the request without bouncing across separate screens.',
        ),
        const SizedBox(height: 20),
        AppSurface(
          radius: AppTheme.radii.xl,
          padding: const EdgeInsets.all(44),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool stacked = constraints.maxWidth < 980;

              final Widget primary = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radii.lg),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: const Icon(
                      Icons.file_upload_outlined,
                      color: AppTheme.secondary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Drop your files here',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      files.isEmpty
                          ? 'Select images or ZIP/TAR archives and the filter window will open immediately on top of this screen.'
                          : 'Your files are staged. Open the filter window to review settings or start processing.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton(
                        onPressed: _isPickingFiles ? null : _addFiles,
                        child: Text(
                          _isPickingFiles ? 'Opening picker...' : 'Choose Images',
                        ),
                      ),
                      if (files.isNotEmpty)
                        OutlinedButton(
                          onPressed: _openBatchBuilder,
                          child: const Text('Open Filters'),
                        ),
                    ],
                  ),
                  if (_isPickingFiles) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      'Waiting for file selection...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slate,
                      ),
                    ),
                  ],
                ],
              );

              final Widget metrics = Container(
                width: stacked ? double.infinity : 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Batch snapshot',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: <Widget>[
                        MiniLabel(label: 'Images', value: '${files.length}'),
                        MiniLabel(
                          label: 'Total size',
                          value: '${totalSize.toStringAsFixed(1)} MB',
                        ),
                        MiniLabel(
                          label: 'Next step',
                          value: files.isEmpty
                              ? 'Select files'
                              : 'Open filter window',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Supports JPG, PNG, WEBP, BMP, GIF, TIFF, ICO, ZIP, TAR and TAR.GZ/TGZ. Large images are optimized automatically and each batch is capped at 8 MB to avoid server rejection.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    primary,
                    const SizedBox(height: 24),
                    metrics,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: primary),
                  const SizedBox(width: 28),
                  metrics,
                ],
              );
            },
          ),
        ),
        if (files.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          SectionPanel(
            title: 'Staged images',
            description:
                'A quick read on what is about to enter the distributed processing pipeline.',
            action: TextButton(
              onPressed: workspace.clearFiles,
              child: const Text('Clear all'),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int crossAxisCount = constraints.maxWidth >= 1200
                    ? 5
                    : constraints.maxWidth >= 900
                    ? 4
                    : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: files.map((UploadFileItem file) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radii.lg,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.outlineVariant,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radii.lg,
                                  ),
                                  child: Image.memory(
                                    file.bytes,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stackTrace,
                                    ) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: AppTheme.onSurfaceVariant,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: () => workspace.removeFile(file.id),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radii.pill,
                                  ),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: AppTheme.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          file.name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          file.sizeLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _BatchBuilderSheet extends StatefulWidget {
  const _BatchBuilderSheet({required this.onStarted});

  final VoidCallback onStarted;

  @override
  State<_BatchBuilderSheet> createState() => _BatchBuilderSheetState();
}

class _BatchBuilderSheetState extends State<_BatchBuilderSheet> {
  static const List<_TransformOption> _quickTransforms = <_TransformOption>[
    _TransformOption(label: 'Grayscale', value: 'grayscale'),
    _TransformOption(label: 'Flip Horizontal', value: 'flip_horizontal'),
    _TransformOption(label: 'Sharpen', value: 'sharpen'),
    _TransformOption(label: 'Extract Text (OCR)', value: 'ocr'),
  ];

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

  void _applyAndClose() {
    final workspace = WorkspaceScope.of(context);
    workspace.setSelectedFilters(
      buildBackendFilters(
        toggles: _transforms,
        brightnessPercent: _brightness,
        contrastPercent: _contrast,
        blurRadius: _blur,
        rotationDegrees: _rotation,
        outputFormat: _format,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _start() async {
    final workspace = WorkspaceScope.of(context);
    workspace.setSelectedFilters(
      buildBackendFilters(
        toggles: _transforms,
        brightnessPercent: _brightness,
        contrastPercent: _contrast,
        blurRadius: _blur,
        rotationDegrees: _rotation,
        outputFormat: _format,
      ),
    );

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
    final double previewScale = _transforms.contains('flip_horizontal') ? -1 : 1;
    final bool grayscale = _transforms.contains('grayscale');
    final bool ocrEnabled = _transforms.contains('ocr');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: AppTheme.softShadow,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Configure batch',
                          style: AppTheme.displayStyle(context, size: 30),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You are still inside the upload flow. Pick the filters, review the preset, and launch the request from here.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                    MiniLabel(label: 'Step 1', value: 'Images selected'),
                    MiniLabel(label: 'Step 2', value: 'Configure filters'),
                    MiniLabel(label: 'Step 3', value: 'Start processing'),
                    MiniLabel(label: 'Files', value: '$fileCount'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool stacked = constraints.maxWidth < 1080;

                  final Widget left = Column(
                    children: <Widget>[
                      AppSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Quick transforms',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _quickTransforms.map(
                                (_TransformOption transform) {
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
                                },
                              ).toList(),
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
                              onChanged: (double value) =>
                                  setState(() => _blur = value),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.slate),
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
                          ],
                        ),
                      ),
                    ],
                  );

                  final Widget right = Column(
                    children: <Widget>[
                      AppSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Preview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 18),
                            AdaptiveGrid(
                              minItemWidth: 220,
                              childAspectRatio: 1.3,
                              children: <Widget>[
                                _PreviewTile(
                                  label: 'Before',
                                  previewBytes: hasFiles
                                      ? workspace.selectedFiles.first.bytes
                                      : null,
                                  grayscale: false,
                                  rotation: 0,
                                  previewScale: 1,
                                  brightness: 100,
                                  contrast: 100,
                                  blur: 0,
                                ),
                                _PreviewTile(
                                  label: 'After',
                                  previewBytes: hasFiles
                                      ? workspace.selectedFiles.first.bytes
                                      : null,
                                  grayscale: grayscale,
                                  rotation: _rotation,
                                  previewScale: previewScale,
                                  brightness: _brightness,
                                  contrast: _contrast,
                                  blur: _blur,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.canvasSoft,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Text(
                                ocrEnabled
                                    ? 'OCR is enabled for this batch, so the pipeline will also try to extract text from the selected images.'
                                    : 'This configuration keeps contrast crisp, adds controlled brightness and avoids over-processing the batch.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.slate),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Output settings',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _supportedOutputFormats.map(
                                (String format) {
                                  return TogglePill(
                                    label: format,
                                    selected: _format == format,
                                    onTap: () => setState(() => _format = format),
                                  );
                                },
                              ).toList(),
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
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: (!hasFiles || _isSubmitting)
                                        ? null
                                        : _applyAndClose,
                                    child: const Text('Apply Filters'),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                          : 'Start Processing',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!hasFiles) ...<Widget>[
                              const SizedBox(height: 10),
                              Text(
                                'Preview mode only. Add images from Upload to enable processing.',
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
                        left,
                        const SizedBox(height: 16),
                        right,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 5, child: left),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: right),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransformOption {
  const _TransformOption({required this.label, required this.value});

  final String label;
  final String value;
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.label,
    required this.previewBytes,
    required this.grayscale,
    required this.rotation,
    required this.previewScale,
    required this.brightness,
    required this.contrast,
    required this.blur,
  });

  final String label;
  final Uint8List? previewBytes;
  final bool grayscale;
  final int rotation;
  final double previewScale;
  final double brightness;
  final double contrast;
  final double blur;

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
                (brightness / 200).clamp(0, 1),
              )!,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppTheme.navy.withValues(
                    alpha: (blur / 100).clamp(0, 0.1),
                  ),
                  blurRadius: 20 + blur,
                  spreadRadius: -18,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 220),
                turns: rotation / 360,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(previewScale, 1, 1),
                  child: ColorFiltered(
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
                    child: Opacity(
                      opacity: (contrast / 200).clamp(0.35, 1),
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
