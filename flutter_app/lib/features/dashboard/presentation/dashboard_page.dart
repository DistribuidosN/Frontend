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
        _DashboardHero(
          current: current,
          window: _window,
          totalProcessed: totalProcessed,
          queuePeak: queuePeak,
          onWindowChanged: (DashboardWindow window) {
            setState(() => _window = window);
          },
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 250,
          childAspectRatio: 1.55,
          children: current.cards.asMap().entries.map((
            MapEntry<int, OverviewMetric> entry,
          ) {
            final OverviewMetric card = entry.value;
            final _OverviewCardStyle style = _overviewCardStyle(entry.key);

            return AppSurface(
              radius: 26,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  style.background,
                  AppTheme.sand.withValues(alpha: 0.92),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: style.iconBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(card.icon, size: 20, color: style.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          card.label,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ),
                      StatusChip(
                        label: style.badge,
                        color: style.color,
                        background: style.background,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card.value,
                    style: AppTheme.displayStyle(
                      context,
                      size: 30,
                      color: style.textColor,
                    ),
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
                color: AppTheme.sapphire,
                background: AppTheme.sapphireSoft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.canvasWarm,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.borderSoft),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            current.focus,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.inkSoft,
                                  height: 1.6,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.insights_rounded,
                          color: AppTheme.sapphire,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          AppTheme.sand,
                          AppTheme.gold.withValues(alpha: 0.14),
                        ],
                      ),
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

class _OverviewCardStyle {
  const _OverviewCardStyle({
    required this.color,
    required this.textColor,
    required this.background,
    required this.iconBackground,
    required this.badge,
  });

  final Color color;
  final Color textColor;
  final Color background;
  final Color iconBackground;
  final String badge;
}

_OverviewCardStyle _overviewCardStyle(int index) {
  switch (index) {
    case 0:
      return const _OverviewCardStyle(
        color: AppTheme.navy,
        textColor: AppTheme.ink,
        background: AppTheme.sand,
        iconBackground: AppTheme.gold,
        badge: 'volume',
      );
    case 1:
      return const _OverviewCardStyle(
        color: AppTheme.orange,
        textColor: AppTheme.ink,
        background: AppTheme.sand,
        iconBackground: AppTheme.sand,
        badge: 'speed',
      );
    default:
      return const _OverviewCardStyle(
        color: AppTheme.red,
        textColor: AppTheme.ink,
        background: AppTheme.sand,
        iconBackground: AppTheme.sand,
        badge: 'attention',
      );
  }
}

_BatchVisual _batchVisual(BatchStatus status) {
  switch (status) {
    case BatchStatus.running:
      return const _BatchVisual(
        label: 'running',
        color: AppTheme.red,
        background: AppTheme.sand,
        icon: Icons.autorenew_rounded,
      );
    case BatchStatus.completed:
      return const _BatchVisual(
        label: 'completed',
        color: AppTheme.statusGreen,
        background: AppTheme.sand,
        icon: Icons.check_circle_outline,
      );
    case BatchStatus.review:
      return const _BatchVisual(
        label: 'review',
        color: AppTheme.goldDeep,
        background: AppTheme.sand,
        icon: Icons.warning_amber_outlined,
      );
  }
}

Color _toneColor(NodeTone tone) {
  switch (tone) {
    case NodeTone.stable:
      return AppTheme.ink;
    case NodeTone.balancing:
      return AppTheme.goldDeep;
    case NodeTone.warm:
      return AppTheme.orange;
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.current,
    required this.window,
    required this.totalProcessed,
    required this.queuePeak,
    required this.onWindowChanged,
  });

  final DashboardView current;
  final DashboardWindow window;
  final int totalProcessed;
  final int queuePeak;
  final ValueChanged<DashboardWindow> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 34,
      color: AppTheme.white,
      padding: const EdgeInsets.all(30),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget overview = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'OPERATIONAL OVERVIEW',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.slate,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Dashboard',
                style: AppTheme.displayStyle(context, size: 30),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 940),
                child: Text(
                  current.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.slate,
                    height: 1.65,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.sand.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppTheme.borderSoft),
                ),
                child: LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints statConstraints) {
                        final bool compactStats =
                            statConstraints.maxWidth < 640;
                        final List<Widget> statTiles = <Widget>[
                          _DashboardHeroStat(
                            label: 'Processed',
                            value: '$totalProcessed',
                            note: 'in this window',
                            icon: Icons.image_outlined,
                          ),
                          _DashboardHeroStat(
                            label: 'Throughput',
                            value: current.support[0].value,
                            note: 'live pace',
                            icon: Icons.show_chart_rounded,
                          ),
                          _DashboardHeroStat(
                            label: 'Recovery',
                            value: current.support[2].value,
                            note: 'buffer',
                            icon: Icons.timelapse_outlined,
                          ),
                        ];

                        if (compactStats) {
                          return Column(
                            children: <Widget>[
                              for (
                                int index = 0;
                                index < statTiles.length;
                                index++
                              )
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == statTiles.length - 1
                                        ? 0
                                        : 12,
                                  ),
                                  child: statTiles[index],
                                ),
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            Expanded(child: statTiles[0]),
                            const _DashboardHeroDivider(),
                            Expanded(child: statTiles[1]),
                            const _DashboardHeroDivider(),
                            Expanded(child: statTiles[2]),
                          ],
                        );
                      },
                ),
              ),
            ],
          );

          final Widget signalRow = AppSurface(
            radius: 28,
            color: AppTheme.white,
            padding: const EdgeInsets.all(22),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints rowConstraints) {
                final bool stackedSections = rowConstraints.maxWidth < 920;

                final Widget windowSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'WINDOW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.slate,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      window.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Switch the time window to compare load and recovery.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slate,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DashboardWindow.values.map((
                        DashboardWindow item,
                      ) {
                        return TogglePill(
                          label: item.label,
                          selected: window == item,
                          onTap: () => onWindowChanged(item),
                        );
                      }).toList(),
                    ),
                  ],
                );

                final Widget queueSection = Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.sand.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderSoft),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'QUEUE PEAK',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.orange,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$queuePeak',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppTheme.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'highest queued load',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                );

                final Widget healthSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '8 nodes healthy',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.focus,
                      maxLines: stackedSections ? null : 2,
                      overflow: stackedSections ? null : TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.inkSoft,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder:
                          (
                            BuildContext context,
                            BoxConstraints infoConstraints,
                          ) {
                            final bool compactInfo =
                                infoConstraints.maxWidth < 320;

                            if (compactInfo) {
                              return Column(
                                children: <Widget>[
                                  _SignalMiniStat(
                                    label: 'Utilization',
                                    value: current.support[1].value,
                                  ),
                                  const SizedBox(height: 10),
                                  _SignalMiniStat(
                                    label: 'Recovery',
                                    value: current.support[2].value,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: <Widget>[
                                Expanded(
                                  child: _SignalMiniStat(
                                    label: 'Utilization',
                                    value: current.support[1].value,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SignalMiniStat(
                                    label: 'Recovery',
                                    value: current.support[2].value,
                                  ),
                                ),
                              ],
                            );
                          },
                    ),
                  ],
                );

                if (stackedSections) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      windowSection,
                      const SizedBox(height: 16),
                      queueSection,
                      const SizedBox(height: 16),
                      healthSection,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 4, child: windowSection),
                    const _DashboardHeroDivider(height: 118),
                    SizedBox(width: 170, child: queueSection),
                    const _DashboardHeroDivider(height: 118),
                    Expanded(flex: 5, child: healthSection),
                  ],
                );
              },
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[overview, const SizedBox(height: 22), signalRow],
          );
        },
      ),
    );
  }
}

class _DashboardHeroStat extends StatelessWidget {
  const _DashboardHeroStat({
    required this.label,
    required this.value,
    required this.note,
    required this.icon,
  });

  final String label;
  final String value;
  final String note;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 18, color: AppTheme.navy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.slate,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.ink),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardHeroDivider extends StatelessWidget {
  const _DashboardHeroDivider({this.height = 54});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: AppTheme.borderSoft,
    );
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  toneColor.withValues(alpha: 0.08),
                  AppTheme.sand,
                ],
              ),
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
                      StatusChip(
                        label: node.throughput,
                        color: toneColor,
                        background: toneColor.withValues(alpha: 0.08),
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
      color: AppTheme.sand,
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
            _LegendSwatch(color: AppTheme.warning, label: 'Queued'),
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
                                  color: AppTheme.warning,
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

class _SignalMiniStat extends StatelessWidget {
  const _SignalMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.sand,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.slate,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
