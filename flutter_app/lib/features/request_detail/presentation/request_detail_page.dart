import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/logs/presentation/log_level_visuals.dart';
import 'package:imageflow_flutter/features/results/domain/batch_gallery_image.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final latestBatch = workspace.latestBatch;
    final galleryImages = workspace.latestBatchImages;
    final logs = workspace.logs.where((l) => l.job == latestBatch?.requestId).toList();

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
                    'Request Details',
                    style: AppTheme.displayStyle(context, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    latestBatch?.requestId ?? 'No active batch',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            if (latestBatch != null && latestBatch.status.toLowerCase() == 'completed')
              FilledButton.icon(
                onPressed: () => workspace.downloadLatestBatchArchive(),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download Results'),
              ),
          ],
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 200,
          childAspectRatio: 1.3,
          children: <Widget>[
            SummaryMetricCard(
              label: 'Status',
              value: latestBatch?.status ?? 'N/A',
              color: latestBatch?.status.toLowerCase() == 'completed' ? AppTheme.success : AppTheme.goldDeep,
            ),
            SummaryMetricCard(
              label: 'Images',
              value: '${latestBatch?.fileCount ?? 0}',
              color: AppTheme.ink,
            ),
            SummaryMetricCard(
              label: 'Transformations',
              value: '${latestBatch?.filters.length ?? 0}',
              color: AppTheme.ink,
            ),
            SummaryMetricCard(
              label: 'Duration',
              value: 'Real-time',
              color: AppTheme.ink,
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1100;

            final Widget detailsPanel = Expanded(
              flex: stacked ? 0 : 2,
              child: SectionPanel(
                title: 'Image Processing Details',
                child: Column(
                  children: <Widget>[
                    if (galleryImages.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No images processed yet or still loading...'),
                      )
                    else
                      ...galleryImages.map((BatchGalleryImage image) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.canvasSoft,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                image.resultUrl.isNotEmpty
                                    ? Icons.check_circle_outline
                                    : Icons.pending_outlined,
                                color: image.resultUrl.isNotEmpty
                                    ? AppTheme.success
                                    : AppTheme.goldDeep,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      image.originalName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Node: ${image.nodeId}',
                                      style: Theme.of(context).textTheme.bodySmall
                                          ?.copyWith(color: AppTheme.slate),
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                label: image.status,
                                color: image.status.toLowerCase() == 'completed' || image.status.toLowerCase() == 'finished'
                                    ? AppTheme.statusGreen
                                    : AppTheme.goldDeep,
                                background: AppTheme.sand,
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );

            final Widget transformPanel = Expanded(
              child: SectionPanel(
                title: 'Transformations',
                child: Column(
                  children: (latestBatch?.filters ?? []).map((String filter) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.canvasSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              filter,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  detailsPanel,
                  const SizedBox(height: 16),
                  transformPanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                detailsPanel,
                const SizedBox(width: 16),
                transformPanel,
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'Processing Logs',
          child: Column(
            children: logs.isEmpty 
              ? [const Padding(padding: EdgeInsets.all(20), child: Text('No logs for this request.'))]
              : logs.map((LogEntry log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.canvasSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 74,
                      child: Text(
                        log.time,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ),
                    StatusChip(
                      label: logLevelLabel(log.level),
                      color: logLevelColor(log.level),
                      background: logLevelBackground(log.level),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log.message,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.ink),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
