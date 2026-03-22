import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/logs/presentation/log_level_visuals.dart';
import 'package:imageflow_flutter/features/request_detail/data/request_detail_mock_data.dart';
import 'package:imageflow_flutter/features/request_detail/domain/request_detail_models.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'req-4522',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download Results'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 200,
          childAspectRatio: 1.3,
          children: const <Widget>[
            SummaryMetricCard(
              label: 'Status',
              value: 'Completed',
              color: AppTheme.success,
            ),
            SummaryMetricCard(
              label: 'Images',
              value: '24',
              color: AppTheme.ink,
            ),
            SummaryMetricCard(
              label: 'Submitted',
              value: 'Mar 19',
              color: AppTheme.ink,
            ),
            SummaryMetricCard(
              label: 'Duration',
              value: '52 sec',
              color: AppTheme.ink,
            ),
            SummaryMetricCard(label: 'Nodes', value: '8', color: AppTheme.ink),
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
                    ...requestImageDetails.map((RequestImageDetail image) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.canvasSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    image.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Node: ${image.node}  |  ${image.start} -> ${image.end}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppTheme.slate),
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              label: image.status,
                              color: AppTheme.success,
                              background: AppTheme.successSoft,
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Show all 24 images'),
                    ),
                  ],
                ),
              ),
            );

            final Widget transformPanel = Expanded(
              child: SectionPanel(
                title: 'Transformations',
                child: Column(
                  children: transformationDetails.map((
                    TransformationDetail transform,
                  ) {
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
                              transform.name,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          Text(
                            transform.value,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.slate),
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
            children: requestLogs.map((LogEntry log) {
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
