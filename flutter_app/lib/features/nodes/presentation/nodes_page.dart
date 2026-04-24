import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/admin/domain/admin_node_metric.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class NodesPage extends StatelessWidget {
  const NodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final List<AdminNodeMetric> workerNodes = workspace.adminNodeMetrics;
    final int activeCount = workerNodes
        .where((AdminNodeMetric node) => node.active)
        .length;
    final int avgLoad = workerNodes.isEmpty
        ? 0
        : (workerNodes.fold<int>(
                    0,
                    (int acc, AdminNodeMetric node) => acc + node.load,
                  ) /
                  workerNodes.length)
              .round();
    final int totalJobs = workerNodes.fold<int>(
      0,
      (int acc, AdminNodeMetric node) => acc + node.currentJobs,
    );
    final int totalProcessed = workerNodes.fold<int>(
      0,
      (int acc, AdminNodeMetric node) => acc + node.totalProcessed,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PageIntro(
          kicker: 'Capacity',
          title: 'Worker nodes',
          description:
              'Read the backend node metrics endpoint for the configured node lookup.',
          actions: OutlinedButton.icon(
            onPressed: () => workspace.refreshAdminMetrics(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh Metrics'),
          ),
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 220,
          childAspectRatio: 1.22,
          children: <Widget>[
            SummaryMetricCard(
              label: 'Active nodes',
              value: workerNodes.isEmpty ? '--' : '$activeCount/${workerNodes.length}',
              color: AppTheme.success,
            ),
            SummaryMetricCard(
              label: 'Average load',
              value: workerNodes.isEmpty ? '--' : '$avgLoad%',
              color: AppTheme.ink,
            ),
            SummaryMetricCard(
              label: 'Active jobs',
              value: workerNodes.isEmpty ? '--' : '$totalJobs',
              color: AppTheme.goldDeep,
            ),
            SummaryMetricCard(
              label: 'Total processed',
              value: workerNodes.isEmpty ? '--' : '$totalProcessed',
              color: AppTheme.red,
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppSurface(
          radius: AppTheme.radii.xl,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              const StatusChip(
                label: 'Backend endpoint',
                color: AppTheme.goldDeep,
                background: AppTheme.sand,
                icon: Icons.link_rounded,
              ),
              StatusChip(
                label: workspace.adminMetricNodeId,
                color: AppTheme.navy,
                background: AppTheme.surfaceContainer,
                icon: Icons.dns_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (workerNodes.isEmpty)
          AppSurface(
            child: Text(
              'The backend returned no node metrics for ${workspace.adminMetricNodeId}.',
            ),
          )
        else
          AdaptiveGrid(
            minItemWidth: 420,
            childAspectRatio: 1.34,
            children: workerNodes.map((AdminNodeMetric node) {
              final Color loadStart = node.load >= 80
                  ? AppTheme.danger
                  : node.load >= 60
                  ? AppTheme.warning
                  : AppTheme.gold;
              final Color loadEnd = node.load >= 80
                  ? AppTheme.red
                  : node.load >= 60
                  ? AppTheme.orange
                  : AppTheme.goldDeep;

              return AppSurface(
                radius: 16,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                AppTheme.canvasSoft,
                                AppTheme.border,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.dns_outlined,
                            size: 24,
                            color: AppTheme.slate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: node.active
                                          ? AppTheme.success
                                          : AppTheme.danger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      node.id,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                node.address.isEmpty ? 'No address returned' : node.address,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.slate,
                                      fontFamily: 'monospace',
                                    ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label: node.active ? 'active' : 'inactive',
                          color: node.active ? AppTheme.success : AppTheme.danger,
                          background: node.active
                              ? AppTheme.successSoft
                              : AppTheme.dangerSoft,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Text(
                          'Current Load',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                        ),
                        const Spacer(),
                        Text(
                          '${node.load}%',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _GradientProgressLine(
                      value: node.load / 100,
                      startColor: loadStart,
                      endColor: loadEnd,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppTheme.border)),
                      ),
                      child: Wrap(
                        spacing: 18,
                        runSpacing: 14,
                        children: <Widget>[
                          SizedBox(
                            width: 86,
                            child: MiniLabel(
                              label: 'Active Jobs',
                              value: '${node.currentJobs}',
                            ),
                          ),
                          SizedBox(
                            width: 88,
                            child: MiniLabel(
                              label: 'Processed',
                              value: '${node.totalProcessed}',
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: MiniLabel(
                              label: 'Uptime',
                              value: node.uptime.isEmpty ? 'No data' : node.uptime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppTheme.border)),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: AppTheme.slate,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              node.lastHeartbeat.isEmpty
                                  ? 'No heartbeat returned by backend'
                                  : 'Last heartbeat: ${node.lastHeartbeat}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _GradientProgressLine extends StatelessWidget {
  const _GradientProgressLine({
    required this.value,
    required this.startColor,
    required this.endColor,
  });

  final double value;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        color: AppTheme.sand,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[startColor, endColor],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
