import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/results/data/results_mock_data.dart';
import 'package:imageflow_flutter/features/results/domain/result_asset.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final latestBatch = workspace.latestBatch;
    final List<String> filters = latestBatch?.filters ?? sampleTransforms;

    final List<ResultAsset> assets = latestBatch == null
        ? resultAssets
        : latestBatch.fileNames
              .map(
                (String fileName) => ResultAsset(
                  id: latestBatch.fileNames.indexOf(fileName) + 1,
                  name: fileName,
                  size:
                      workspace.selectedFiles
                          .where((file) => file.name == fileName)
                          .map((file) => file.sizeLabel)
                          .cast<String?>()
                          .firstWhere(
                            (String? size) => size != null,
                            orElse: () => 'pending',
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
                              : '${latestBatch.fileCount} images - Request ${latestBatch.requestId}',
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
                    label: 'Output Size',
                    value: assets.isEmpty ? 'pending' : assets.first.size,
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
          description: 'A quick side-by-side check of representative output.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: AdaptiveGrid(
                  minItemWidth: 320,
                  childAspectRatio: 1.68,
                  children: const <Widget>[
                    ImageComparisonCard(label: 'Before', grayscale: false),
                    ImageComparisonCard(label: 'After', grayscale: true),
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
              TogglePill(label: 'Grid View', selected: true, onTap: () {}),
              const SizedBox(width: 8),
              TogglePill(label: 'List View', selected: false, onTap: () {}),
            ],
          ),
          child: LayoutBuilder(
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
                children: assets.map((ResultAsset result) {
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
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.image_outlined,
                                  size: 32,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SmallIconButton(
                                      icon: Icons.zoom_in_rounded,
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    SmallIconButton(
                                      icon: Icons.download_rounded,
                                      onTap: () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        try {
                                          final String location =
                                              await workspace
                                                  .downloadResultImage(
                                                    result.name,
                                                  );
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
                                              content: Text(error.toString()),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
          ),
        ),
      ],
    );
  }
}
