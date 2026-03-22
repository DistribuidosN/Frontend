import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/dashboard/data/dashboard_mock_data.dart';
import 'package:imageflow_flutter/features/dashboard/domain/dashboard_models.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardWindow _window = DashboardWindow.week;

  @override
  Widget build(BuildContext context) {
    final DashboardView current = dashboardViews[_window]!;
    final int totalProcessed = current.chart.fold<int>(
      0,
      (int sum, ThroughputPoint item) => sum + item.processed,
    );
    final int queuePeak = current.chart.fold<int>(
      0,
      (int maxValue, ThroughputPoint item) => math.max(maxValue, item.queued),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PageIntro(
          kicker: 'Operational Overview',
          title: 'Dashboard',
          description: current.summary,
          actions: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DashboardWindow.values.map((DashboardWindow window) {
                  return TogglePill(
                    label: window.label,
                    selected: _window == window,
                    onTap: () => setState(() => _window = window),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: AppSurface(
                  radius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '8 nodes healthy',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current.focus,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 250,
          childAspectRatio: 1.55,
          children: current.cards.map((OverviewMetric card) {
            return AppSurface(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.canvasSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(card.icon, size: 20, color: AppTheme.ink),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          card.label,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card.value,
                    style: AppTheme.displayStyle(context, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.note,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1120;
            const double desktopTopPanelMinHeight = 820;
            final Widget throughputPanel = SectionPanel(
              title: 'Throughput',
              description: 'Processed volume against queued pressure.',
              action: StatusChip(
                label: 'Queue peak $queuePeak',
                color: AppTheme.slate,
                background: Colors.white,
              ),
              child: Column(
                children: <Widget>[
                  AdaptiveGrid(
                    minItemWidth: 220,
                    childAspectRatio: 1.8,
                    children: <Widget>[
                      _SupportMetricCard(
                        label: 'Processed',
                        value: totalProcessed.toString(),
                        note: 'current window',
                      ),
                      _SupportMetricCard(
                        label: current.support[0].label,
                        value: current.support[0].value,
                        note: current.support[0].note,
                      ),
                      _SupportMetricCard(
                        label: current.support[2].label,
                        value: current.support[2].value,
                        note: current.support[2].note,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ThroughputChart(
                    data: current.chart,
                    height: stacked ? 320 : 520,
                  ),
                ],
              ),
            );

            final Widget clusterPanel = SectionPanel(
              title: 'Cluster Status',
              description: 'Node pressure and recovery room.',
              child: _ClusterStatusPanel(current: current),
            );

            final Widget recentBatchesPanel = SectionPanel(
              title: 'Recent Batches',
              description: 'The active worklist.',
              action: OutlinedButton(
                onPressed: () {},
                child: const Text('Export activity'),
              ),
              child: Column(
                children: recentBatches.map((BatchActivity batch) {
                  final _BatchVisual style = _batchVisual(batch.status);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppSurface(
                      padding: const EdgeInsets.all(18),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              final bool stacked = constraints.maxWidth < 920;
                              final Widget meta = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        batch.id,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      StatusChip(
                                        label: style.label,
                                        color: style.color,
                                        background: style.background,
                                        icon: style.icon,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${batch.preset} for ${batch.owner}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppTheme.slate),
                                  ),
                                ],
                              );

                              final Widget progress = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Completion',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: AppTheme.slate),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${batch.completion}%',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ProgressLine(
                                    value: batch.completion / 100,
                                    color: style.color,
                                  ),
                                ],
                              );

                              if (stacked) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    meta,
                                    const SizedBox(height: 14),
                                    Row(
                                      children: <Widget>[
                                        MiniLabel(
                                          label: 'Images',
                                          value: '${batch.images}',
                                        ),
                                        const SizedBox(width: 16),
                                        MiniLabel(
                                          label: 'ETA',
                                          value: batch.eta,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    progress,
                                  ],
                                );
                              }

                              return Row(
                                children: <Widget>[
                                  Expanded(flex: 4, child: meta),
                                  Expanded(
                                    child: MiniLabel(
                                      label: 'Images',
                                      value: '${batch.images}',
                                    ),
                                  ),
                                  Expanded(
                                    child: MiniLabel(
                                      label: 'ETA',
                                      value: batch.eta,
                                    ),
                                  ),
                                  Expanded(flex: 2, child: progress),
                                ],
                              );
                            },
                      ),
                    ),
                  );
                }).toList(),
              ),
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  throughputPanel,
                  const SizedBox(height: 20),
                  clusterPanel,
                  const SizedBox(height: 20),
                  recentBatchesPanel,
                ],
              );
            }

            return Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 10,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: desktopTopPanelMinHeight,
                        ),
                        child: throughputPanel,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: desktopTopPanelMinHeight,
                        ),
                        child: clusterPanel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                recentBatchesPanel,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BatchVisual {
  const _BatchVisual({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
}

_BatchVisual _batchVisual(BatchStatus status) {
  switch (status) {
    case BatchStatus.running:
      return const _BatchVisual(
        label: 'running',
        color: AppTheme.warning,
        background: Colors.white,
        icon: Icons.autorenew_rounded,
      );
    case BatchStatus.completed:
      return const _BatchVisual(
        label: 'completed',
        color: AppTheme.success,
        background: AppTheme.successSoft,
        icon: Icons.check_circle_outline,
      );
    case BatchStatus.review:
      return const _BatchVisual(
        label: 'review',
        color: AppTheme.info,
        background: AppTheme.infoSoft,
        icon: Icons.warning_amber_outlined,
      );
  }
}

Color _toneColor(NodeTone tone) {
  switch (tone) {
    case NodeTone.stable:
      return AppTheme.ink;
    case NodeTone.balancing:
      return AppTheme.warning;
    case NodeTone.warm:
      return AppTheme.danger;
  }
}

class _ClusterStatusPanel extends StatelessWidget {
  const _ClusterStatusPanel({required this.current});

  final DashboardView current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...clusterNodes.map((NodeHealth node) {
          final Color toneColor = _toneColor(node.tone);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: toneColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        node.id,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      Text(
                        node.throughput,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Text(
                        node.zone,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                      const Spacer(),
                      Text(
                        '${node.load}% load',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ProgressLine(value: node.load / 100, color: toneColor),
                ],
              ),
            ),
          );
        }),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool singleColumn = constraints.maxWidth < 420;
            return AdaptiveGrid(
              minItemWidth: singleColumn ? constraints.maxWidth : 180,
              childAspectRatio: singleColumn ? 2.2 : 1.15,
              children: <Widget>[
                _SupportMetricCard(
                  label: current.support[1].label,
                  value: current.support[1].value,
                  note: current.support[1].note,
                ),
                _SupportMetricCard(
                  label: current.support[2].label,
                  value: current.support[2].value,
                  note: current.support[2].note,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SupportMetricCard extends StatelessWidget {
  const _SupportMetricCard({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.4,
              color: AppTheme.slate,
            ),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
          ),
        ],
      ),
    );
  }
}

class ThroughputChart extends StatelessWidget {
  const ThroughputChart({super.key, required this.data, this.height = 340});

  final List<ThroughputPoint> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final int maxValue = data.fold<int>(
      1,
      (int value, ThroughputPoint point) =>
          math.max(value, math.max(point.processed, point.queued)),
    );
    final double barAreaHeight = math.max(220, height - 90);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: const <Widget>[
            _LegendSwatch(color: AppTheme.ink, label: 'Processed'),
            SizedBox(width: 18),
            _LegendSwatch(color: AppTheme.gold, label: 'Queued'),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((ThroughputPoint point) {
              final double processedHeight =
                  barAreaHeight * point.processed / maxValue;
              final double queuedHeight =
                  barAreaHeight * point.queued / maxValue;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: processedHeight,
                                decoration: BoxDecoration(
                                  color: AppTheme.ink,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 20,
                                height: queuedHeight,
                                decoration: BoxDecoration(
                                  color: AppTheme.gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        point.label,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: <Widget>[
                          Text(
                            '${point.processed}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${point.queued} queued',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.slate),
                          ),
                        ],
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

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
        ),
      ],
    );
  }
}
