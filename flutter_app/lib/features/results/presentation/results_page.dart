import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/results/data/results_mock_data.dart';
import 'package:imageflow_flutter/features/results/domain/batch_gallery_image.dart';
import 'package:imageflow_flutter/features/results/domain/result_asset.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _gridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkspaceScope.of(context).refreshLatestBatchImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final latestBatch = workspace.latestBatch;
    final List<String> filters = latestBatch?.filters ?? sampleTransforms;
    final previewFile = workspace.selectedFiles.isEmpty
        ? null
        : workspace.selectedFiles.first;
    final List<BatchGalleryImage> galleryImages = workspace.latestBatchImages;

    final List<ResultAsset> assets = latestBatch == null
        ? resultAssets
        : (galleryImages.isNotEmpty
                  ? galleryImages
                  : latestBatch.fileNames.asMap().entries.map(
                      (MapEntry<int, String> entry) => BatchGalleryImage(
                        imageUuid: '${entry.key}',
                        batchUuid: latestBatch.requestId,
                        originalName: entry.value,
                        resultUrl: '',
                        status: latestBatch.status,
                        nodeId: '-',
                      ),
                    ))
              .map(
                (BatchGalleryImage image) => ResultAsset(
                  id: galleryImages.isNotEmpty
                      ? galleryImages.indexOf(image) + 1
                      : latestBatch.fileNames.indexOf(image.originalName) + 1,
                  name: image.originalName,
                  size:
                      workspace.selectedFiles
                          .where((file) => file.name == image.originalName)
                          .map((file) => file.sizeLabel)
                          .cast<String?>()
                          .firstWhere(
                            (String? size) => size != null,
                            orElse: () => galleryImages.isNotEmpty ? 'ready' : 'pending',
                          ) ??
                      'pending',
                  transforms: filters,
                ),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PageIntro(
          kicker: 'Completed request',
          title: 'Processing results',
          description:
              'Review the last batch submitted from the workspace and verify exactly what went out to the backend.',
          actions: FilledButton.icon(
            onPressed: latestBatch == null
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final String location = await workspace
                          .downloadLatestBatchArchive();
                      if (!context.mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        SnackBar(content: Text('Archive saved to $location')),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download All (ZIP)'),
          ),
        ),
        const SizedBox(height: 20),
        AppSurface(
          radius: AppTheme.radii.xl,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.successSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radii.md),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          latestBatch?.message ??
                              'All images processed successfully',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latestBatch == null
                              ? '24 images - Completed in 52 seconds'
                              : '${latestBatch.fileCount} images - Batch ${latestBatch.requestId}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AdaptiveGrid(
                minItemWidth: 180,
                childAspectRatio: 1.5,
                children: <Widget>[
                  SummaryMetricCard(
                    label: 'Total Images',
                    value: '${latestBatch?.fileCount ?? assets.length}',
                    color: AppTheme.ink,
                  ),
                  SummaryMetricCard(
                    label: 'Status',
                    value: latestBatch?.status ?? 'complete',
                    color: AppTheme.success,
                  ),
                  SummaryMetricCard(
                    label: 'Filters',
                    value: '${filters.length}',
                    color: AppTheme.ink,
                  ),
                  SummaryMetricCard(
                    label: 'Outputs',
                    value: '${galleryImages.isEmpty ? assets.length : galleryImages.length}',
                    color: AppTheme.ink,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'Applied Filters',
          description: 'Filters included in the latest batch request.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: filters
                .map(
                  (String transform) => StatusChip(
                    label: transform,
                    color: AppTheme.ink,
                    background: AppTheme.surfaceContainer,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'Sample Comparison',
          description:
              'A clearer before-and-after view of one representative image from the latest batch.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        StatusChip(
                          label: previewFile?.name ?? 'Demo preview',
                          color: AppTheme.ink,
                          background: AppTheme.surfaceContainer,
                          icon: Icons.image_outlined,
                        ),
                        StatusChip(
                          label: galleryImages.isEmpty
                              ? '${filters.length} filters'
                              : '${galleryImages.length} output(s)',
                          color: AppTheme.success,
                          background: AppTheme.successSoft,
                          icon: Icons.tune_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: AdaptiveGrid(
                        minItemWidth: 360,
                        childAspectRatio: 1.08,
                        children: <Widget>[
                          ImageComparisonCard(
                            label: 'Before',
                            grayscale: false,
                            previewBytes: previewFile?.bytes,
                            caption: previewFile == null
                                ? 'No image selected yet. This area will show the original asset.'
                                : 'Original asset staged for processing.',
                          ),
                          ImageComparisonCard(
                            label: 'After',
                            grayscale: true,
                            previewBytes: previewFile?.bytes,
                            caption: filters.isEmpty
                                ? 'Processed output preview will reflect the selected batch settings.'
                                : 'Preview based on ${filters.first} and the rest of the selected transforms.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'All Results',
          description:
              'Browse the filenames that belong to the latest submitted batch.',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TogglePill(
                label: 'Grid View',
                selected: _gridView,
                onTap: () => setState(() => _gridView = true),
              ),
              const SizedBox(width: 8),
              TogglePill(
                label: 'List View',
                selected: !_gridView,
                onTap: () => setState(() => _gridView = false),
              ),
            ],
          ),
          child: _gridView
              ? LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int crossAxisCount = constraints.maxWidth >= 1200
                        ? 4
                        : constraints.maxWidth >= 900
                        ? 3
                        : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.92,
                      children: assets.map((ResultAsset result) {
                        final localFile = workspace.selectedFiles.cast<dynamic>().firstWhere(
                          (dynamic file) => file.name == result.name,
                          orElse: () => null,
                        );
                        final remoteImage = galleryImages.cast<BatchGalleryImage?>().firstWhere(
                          (BatchGalleryImage? image) => image?.originalName == result.name,
                          orElse: () => null,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radii.lg,
                                  ),
                                  border: Border.all(color: AppTheme.outlineVariant),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    if (localFile != null)
                                      Image.memory(localFile.bytes, fit: BoxFit.cover)
                                    else if (remoteImage != null &&
                                        workspace.isReachablePreviewUrl(
                                          remoteImage.resultUrl,
                                        ))
                                      Image.network(
                                        remoteImage.resultUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 32,
                                            color: AppTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      )
                                    else
                                      const Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 32,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    Positioned(
                                      left: 12,
                                      right: 12,
                                      bottom: 12,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SmallIconButton(
                                            icon: Icons.zoom_in_rounded,
                                            onTap: () {
                                              showDialog<void>(
                                                context: context,
                                                builder: (BuildContext dialogContext) {
                                                  return Dialog(
                                                    child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: localFile != null
                                                          ? Image.memory(
                                                              localFile.bytes,
                                                              fit: BoxFit.contain,
                                                            )
                                                          : remoteImage != null &&
                                                                  workspace.isReachablePreviewUrl(
                                                                    remoteImage.resultUrl,
                                                                  )
                                                              ? Image.network(
                                                                  remoteImage.resultUrl,
                                                                  fit: BoxFit.contain,
                                                                )
                                                              : const Center(
                                                                  child: Text(
                                                                    'Preview not available for this image.',
                                                                  ),
                                                                ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          SmallIconButton(
                                            icon: Icons.download_rounded,
                                            onTap: () async {
                                              final messenger = ScaffoldMessenger.of(
                                                context,
                                              );
                                              try {
                                                final String location = await workspace
                                                    .downloadResultImage(result.name);
                                                if (!context.mounted) {
                                                  return;
                                                }
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Saved file to $location',
                                                    ),
                                                  ),
                                                );
                                              } catch (error) {
                                                if (!context.mounted) {
                                                  return;
                                                }
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      error.toString(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              result.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              result.size,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                )
              : Column(
                  children: assets.map((ResultAsset result) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppSurface(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(result.name),
                                  const SizedBox(height: 4),
                                  Text(
                                    result.size,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            SmallIconButton(
                              icon: Icons.download_rounded,
                              onTap: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  final String location = await workspace
                                      .downloadResultImage(result.name);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Saved file to $location'),
                                    ),
                                  );
                                } catch (error) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
