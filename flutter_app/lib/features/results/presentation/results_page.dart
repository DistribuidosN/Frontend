import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/history/domain/history_request.dart';
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
  HistoryRequest? _selectedBatch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workspace = WorkspaceScope.of(context);
      workspace.refreshHistory().then((_) {
        if (workspace.latestBatch != null && _selectedBatch == null) {
          try {
            final match = workspace.historyRequests.firstWhere(
              (b) => b.id == workspace.latestBatch!.requestId
            );
            _openBatch(match, workspace);
          } catch (_) {}
        }
      });
    });
  }

  void _openBatch(HistoryRequest batch, dynamic workspace) async {
    setState(() => _selectedBatch = batch);
    await workspace.selectHistoryBatch(batch.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedBatch == null) {
      return _buildBatchList(context);
    } else {
      return _buildBatchDetail(context);
    }
  }

  Widget _buildBatchList(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final history = workspace.historyRequests;

    if (history.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageIntro(
            kicker: 'History',
            title: 'Processed Batches',
            description: 'No batches found. Process some images to see them here.',
            actions: FilledButton.icon(
              onPressed: () => workspace.refreshHistory(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppTheme.onSurfaceVariant),
                  SizedBox(height: 16),
                  Text('No batches found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.ink)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          kicker: 'Batch History',
          title: 'Processed Batches',
          description: 'Double-click a batch to view its processed images and details.',
          actions: FilledButton.icon(
            onPressed: () => workspace.refreshHistory(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
          ),
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 280,
          childAspectRatio: 0.9,
          spacing: 16,
          children: history.map((batch) {
            return InkWell(
              onDoubleTap: () => _openBatch(batch, workspace),
              onTap: () {
                final platform = Theme.of(context).platform;
                if (platform == TargetPlatform.iOS || platform == TargetPlatform.android) {
                  _openBatch(batch, workspace);
                } else {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Double-click to open batch details'), duration: Duration(seconds: 1)),
                  );
                }
              },
              borderRadius: BorderRadius.circular(AppTheme.radii.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radii.lg),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: AppTheme.surfaceRaised,
                        child: batch.coverImageUrl != null && workspace.isReachablePreviewUrl(batch.coverImageUrl!)
                            ? Image.network(
                                batch.coverImageUrl!,
                                fit: BoxFit.cover,
                                headers: workspace.authHeaders,
                                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_outlined, size: 48, color: AppTheme.onSurfaceVariant)),
                              )
                            : const Center(child: Icon(Icons.image_outlined, size: 48, color: AppTheme.onSurfaceVariant)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Batch ${batch.id.substring(0, 8)}...', style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(batch.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StatusChip(
                                  label: '${batch.images} images',
                                  color: AppTheme.ink,
                                  background: AppTheme.surfaceRaised,
                                  icon: Icons.photo_library_outlined,
                                ),
                                StatusChip(
                                  label: batch.status.name.toUpperCase(),
                                  color: switch (batch.status) {
                                    RequestStatus.completed => AppTheme.success,
                                    RequestStatus.failed => AppTheme.error,
                                    RequestStatus.processing => const Color(0xFFE67E22),
                                    RequestStatus.received => const Color(0xFF3498DB),
                                    RequestStatus.pending => AppTheme.onSurfaceVariant,
                                  },
                                  background: switch (batch.status) {
                                    RequestStatus.completed => AppTheme.successSoft,
                                    RequestStatus.failed => AppTheme.dangerSoft,
                                    RequestStatus.processing => const Color(0xFFFEF3E2),
                                    RequestStatus.received => const Color(0xFFEBF5FB),
                                    RequestStatus.pending => AppTheme.surfaceRaised,
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBatchDetail(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final latestBatch = workspace.latestBatch;
    final List<String> filters = latestBatch?.filters ?? const <String>[];
    final previewFile = workspace.selectedFiles.isEmpty
        ? null
        : workspace.selectedFiles.first;
    final List<BatchGalleryImage> galleryImages = workspace.latestBatchImages;

    final List<ResultAsset> assets = latestBatch == null
        ? const <ResultAsset>[]
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
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _selectedBatch = null),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to batches'),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        PageIntro(
          kicker: 'Batch ${_selectedBatch?.id.substring(0, 8) ?? ''}',
          title: 'Batch Details',
          description:
              'Review the results of this batch and verify exactly what was processed by the backend.',
          actions: FilledButton.icon(
            onPressed: _selectedBatch == null
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final String location =
                          await workspace.downloadBatchById(_selectedBatch!.id);
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Archive saved to $location')),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
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
                              ? 'No batch results available'
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
              ? AdaptiveGrid(
                  minItemWidth: 260,
                  childAspectRatio: 0.92,
                  spacing: 16,
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
                                // Show processed result first; fall back to
                                // original local bytes only when no result URL.
                                if (remoteImage != null &&
                                    workspace.isReachablePreviewUrl(
                                      remoteImage.resultUrl,
                                    ))
                                  Image.network(
                                    remoteImage.resultUrl,
                                    fit: BoxFit.cover,
                                    headers: workspace.authHeaders,
                                    errorBuilder: (_, __, ___) =>
                                        localFile != null
                                            ? Image.memory(
                                                localFile.bytes,
                                                fit: BoxFit.cover,
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 32,
                                                  color: AppTheme.onSurfaceVariant,
                                                ),
                                              ),
                                  )
                                else if (localFile != null)
                                  Image.memory(localFile.bytes, fit: BoxFit.cover)
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
                                                  child: remoteImage != null &&
                                                          workspace.isReachablePreviewUrl(
                                                            remoteImage.resultUrl,
                                                          )
                                                      ? Image.network(
                                                          remoteImage.resultUrl,
                                                          fit: BoxFit.contain,
                                                          headers: workspace.authHeaders,
                                                          errorBuilder: (_, __, ___) =>
                                                              localFile != null
                                                                  ? Image.memory(
                                                                      localFile.bytes,
                                                                      fit: BoxFit.contain,
                                                                    )
                                                                  : const Center(
                                                                      child: Text('Preview unavailable'),
                                                                    ),
                                                        )
                                                      : localFile != null
                                                          ? Image.memory(
                                                              localFile.bytes,
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
