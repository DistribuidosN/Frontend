import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_file_item.dart';
import 'package:imageflow_flutter/shared/widgets/batch_pipeline_editor.dart';
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
  @override
  Widget build(BuildContext context) {
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
          child: BatchPipelineEditor(
            title: 'Configure batch',
            subtitle:
                'You are still inside the upload flow. Build the full pipeline, review the preview, and launch the request from here.',
            onClose: () => Navigator.of(context).pop(),
            onApplied: () => Navigator.of(context).pop(),
            onStarted: widget.onStarted,
          ),
        ),
      ),
    );
  }
}
