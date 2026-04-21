import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
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
  Future<void> _addFiles() async {
    final bool picked = await WorkspaceScope.of(context).pickFiles();
    if (!picked && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid image files were selected.')),
      );
    }
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
          kicker: 'Batch intake',
          title: 'Upload images',
          description:
              'Stage a batch of assets, validate them visually and move them into configuration without friction.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 980;

            return GestureDetector(
              onTap: _addFiles,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: wide ? 440 : 380,
                  maxWidth: double.infinity,
                ),
                child: AppSurface(
                  radius: AppTheme.radii.xl,
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 48 : 28,
                    vertical: wide ? 52 : 36,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: wide ? 84 : 72,
                            height: wide ? 84 : 72,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radii.lg,
                              ),
                              border: Border.all(
                                color: AppTheme.outlineVariant,
                              ),
                            ),
                            child: const Icon(
                              Icons.file_upload_outlined,
                              color: AppTheme.secondary,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Drop your images here',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'or click to browse from your computer',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 28),
                          FilledButton(
                            onPressed: _addFiles,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 18,
                              ),
                            ),
                            child: const Text('Browse Files'),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Supports: JPG, PNG, WEBP, BMP, GIF (static), TIFF, ICO. Max 50MB per file.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (files.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          AppSurface(
            radius: AppTheme.radii.xl,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${files.length} images uploaded',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: workspace.clearFiles,
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int crossAxisCount = constraints.maxWidth >= 1200
                        ? 6
                        : constraints.maxWidth >= 900
                        ? 4
                        : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.84,
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
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: AppTheme.onSurfaceVariant,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: InkWell(
                                      onTap: () =>
                                          workspace.removeFile(file.id),
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
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Text(
                      'Total size: ${totalSize.toStringAsFixed(1)} MB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => widget.onNavigate(AppPage.taskBuilder),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.white,
                      ),
                      child: const Text('Continue to Configuration'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
