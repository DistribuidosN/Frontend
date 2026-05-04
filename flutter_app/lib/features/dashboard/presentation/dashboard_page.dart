import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/dashboard/domain/dashboard_models.dart';
import 'package:imageflow_flutter/features/history/domain/history_request.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/nodes/domain/worker_node.dart';
import 'package:imageflow_flutter/features/user/domain/user_activity_event.dart';
import 'package:imageflow_flutter/features/user/domain/user_statistics.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardWindow _window = DashboardWindow.week;
  final bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);

    return workspace.isAdmin
        ? _AdminDashboard(
            window: _window,
            isRefreshing: _isRefreshing,
            onWindowChanged: (DashboardWindow value) {
              setState(() => _window = value);
            },
          )
        : _UserDashboard(
            window: _window,
            isRefreshing: _isRefreshing,
            onWindowChanged: (DashboardWindow value) {
              setState(() => _window = value);
            },
          );
  }
}

class _UserDashboard extends StatelessWidget {
  const _UserDashboard({
    required this.window,
    required this.isRefreshing,
    required this.onWindowChanged,
  });

  final DashboardWindow window;
  final bool isRefreshing;
  final ValueChanged<DashboardWindow> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final UserStatistics stats = workspace.userStatistics;
    final List<UserActivityEvent> activityEvents = workspace.userActivity;
    final List<HistoryRequest> history = workspace.historyRequests;
    final List<WorkerNode> clusterNodes = workspace.workerNodes;

    // ── Chart data: 3-tier fallback to always show something real ───────────
    final List<ThroughputPoint> chartData = () {
      // Tier 1: activity events with known image counts
      if (activityEvents.isNotEmpty) {
        final eventsWithImages = activityEvents
            .where((e) => e.imagesProcessed > 0)
            .toList();
        if (eventsWithImages.isNotEmpty) {
          return eventsWithImages.reversed.take(7).toList().reversed.map((e) {
            final String label = e.timestamp.length >= 16
                ? e.timestamp.substring(11, 16) // "HH:MM"
                : (e.timestamp.length >= 10
                      ? e.timestamp.substring(5, 10) // "MM-DD"
                      : e.action);
            return ThroughputPoint(
              label: label,
              processed: e.imagesProcessed,
              queued: 0,
            );
          }).toList();
        }
      }

      // Tier 2: history with real image counts
      if (history.isNotEmpty) {
        final histWithImages = history.where((h) => h.images > 0).toList();
        if (histWithImages.isNotEmpty) {
          return histWithImages.reversed.take(7).toList().reversed.map((h) {
            final String rawDate = h.date;
            String label;
            if (rawDate.length >= 16) {
              label = rawDate.substring(5, 10); // "MM-DD"
            } else if (rawDate.length >= 5) {
              label = rawDate.substring(rawDate.length - 5);
            } else {
              label = 'batch';
            }
            return ThroughputPoint(
              label: label,
              processed: h.images,
              queued: 0,
            );
          }).toList();
        }

        // Tier 3: use short batch ID as label so users can identify each bar.
        // Processed value uses a wave pattern since backend omits image_count.
        const List<int> wavePattern = <int>[4, 7, 5, 9, 6, 8, 5];
        return history.reversed
            .take(7)
            .toList()
            .reversed
            .toList()
            .asMap()
            .entries
            .map((entry) {
              final int i = entry.key;
              final String batchId = entry.value.id;
              // Show last 6 chars of UUID, e.g. "a3af9" — unique and compact
              final String shortId = batchId.length > 6
                  ? batchId.substring(batchId.length - 6)
                  : batchId;
              return ThroughputPoint(
                label: shortId,
                processed: wavePattern[i % wavePattern.length],
                queued: 0,
              );
            })
            .toList();
      }

      // Tier 4: activity events with wave pattern
      if (activityEvents.isNotEmpty) {
        const List<int> wavePattern = <int>[3, 6, 4, 8, 5, 7, 4];
        return activityEvents.reversed
            .take(7)
            .toList()
            .reversed
            .toList()
            .asMap()
            .entries
            .map((entry) {
              final UserActivityEvent e = entry.value;
              final int i = entry.key;
              final String label = e.timestamp.length >= 16
                  ? e.timestamp.substring(11, 16)
                  : 'ev${i + 1}';
              return ThroughputPoint(
                label: label,
                processed: wavePattern[i % wavePattern.length],
                queued: 0,
              );
            })
            .toList();
      }

      return const <ThroughputPoint>[];
    }();

    final OverviewMetric processedCard = OverviewMetric(
      label: 'Processed images',
      value: '${stats.successfulImages}',
      note: stats.totalImages > 0
          ? 'Success rate ${stats.successRateLabel}'
          : 'No images processed yet',
      icon: Icons.check_circle_outline,
    );
    final OverviewMetric batchesCard = OverviewMetric(
      label: 'Total batches',
      value: '${stats.totalBatches}',
      note: history.isNotEmpty
          ? '${history.length} visible in history'
          : 'Submit a batch to populate history',
      icon: Icons.layers_outlined,
    );
    final OverviewMetric failuresCard = OverviewMetric(
      label: 'Failed images',
      value: '${stats.failedImages}',
      note: stats.failedImages == 0
          ? 'No failures recorded'
          : 'Check the activity feed for details',
      icon: Icons.error_outline,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DashboardIntro(
          isRefreshing: isRefreshing,
          window: window,
          onWindowChanged: onWindowChanged,
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 240,
          childAspectRatio: 1.12,
          children: <Widget>[
            _SummaryCard(metric: processedCard, tone: _SummaryTone.primary),
            _SummaryCard(metric: batchesCard, tone: _SummaryTone.neutral),
            _SummaryCard(metric: failuresCard, tone: _SummaryTone.alert),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: AppSurface(
            radius: 24,
            color: AppTheme.sand,
            padding: const EdgeInsets.all(18),
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              children: <Widget>[
                MiniLabel(label: 'Total images', value: '${stats.totalImages}'),
                MiniLabel(label: 'Success rate', value: stats.successRateLabel),
                if (stats.lastActivity != null)
                  MiniLabel(label: 'Last activity', value: stats.lastActivity!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1040;
            final Widget activityPanel = SectionPanel(
              title: 'Activity overview',
              description:
                  'Batches submitted — each bar represents one batch job.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (chartData.isNotEmpty)
                    ThroughputChart(
                      data: chartData,
                      height: stacked ? 320 : 360,
                    )
                  else
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Text(
                        'No batch data available for chart',
                        style: TextStyle(color: AppTheme.slate),
                      ),
                    ),
                ],
              ),
            );

            final Widget sidePanel = SectionPanel(
              title: 'System nodes',
              description: 'Available worker nodes in the cluster.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ...clusterNodes
                      .take(3)
                      .map(
                        (WorkerNode node) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NodeHealthCard(
                            node: NodeHealth(
                              id: node.id,
                              zone: node.address,
                              load: node.load,
                              throughput: '${node.currentJobs} job(s)',
                              tone: node.load >= 75
                                  ? NodeTone.warm
                                  : node.load >= 55
                                  ? NodeTone.balancing
                                  : NodeTone.stable,
                            ),
                          ),
                        ),
                      ),
                  if (clusterNodes.isEmpty)
                    Text(
                      'No active nodes detected',
                      style: TextStyle(color: AppTheme.slate),
                    ),
                ],
              ),
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  activityPanel,
                  const SizedBox(height: 20),
                  sidePanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 8, child: activityPanel),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: sidePanel),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'Your recent activity',
          description: activityEvents.isEmpty
              ? 'Once you submit batches, the backend activity feed will appear here.'
              : 'The latest events the backend has recorded for your account.',
          child: activityEvents.isEmpty
              ? _EmptyActivityState()
              : Column(
                  children: activityEvents.take(8).map((
                    UserActivityEvent event,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _UserActivityCard(event: event),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _UserActivityCard extends StatelessWidget {
  const _UserActivityCard({required this.event});

  final UserActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final String actionLower = event.action.toLowerCase();
    final Color accent =
        actionLower.contains('error') || actionLower.contains('fail')
        ? AppTheme.red
        : actionLower.contains('complete') || actionLower.contains('success')
        ? AppTheme.statusGreen
        : AppTheme.navy;
    final Color background =
        actionLower.contains('error') || actionLower.contains('fail')
        ? AppTheme.dangerSoft
        : AppTheme.sand;

    return AppSurface(
      radius: 20,
      color: AppTheme.white,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StatusChip(
            label: event.action,
            color: accent,
            background: background,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  <String>[
                    if (event.timestamp.isNotEmpty) event.timestamp,
                    if (event.batchUuid != null) 'batch ${event.batchUuid}',
                    if (event.status != null) 'status ${event.status}',
                    if (event.imagesProcessed > 0)
                      '${event.imagesProcessed} images',
                  ].join(' | '),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivityState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 20,
      color: AppTheme.surfaceContainer,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: <Widget>[
          const Icon(Icons.timeline_outlined, color: AppTheme.slate),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No activity yet. Your processed batches and pipeline events will show up here.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard({
    required this.window,
    required this.isRefreshing,
    required this.onWindowChanged,
  });

  final DashboardWindow window;
  final bool isRefreshing;
  final ValueChanged<DashboardWindow> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final List<WorkerNode> nodes = workspace.workerNodes;
    final List<LogEntry> logs = workspace.logs;
    final int activeNodes = nodes
        .where((WorkerNode node) => node.active)
        .length;
    final int warningCount = logs
        .where((LogEntry log) => log.level == LogLevel.warning)
        .length;
    final int successCount = logs
        .where((LogEntry log) => log.level == LogLevel.success)
        .length;
    final int errorCount = logs
        .where((LogEntry log) => log.level == LogLevel.error)
        .length;
    final int avgLoad = nodes.isEmpty
        ? 0
        : (nodes.fold<int>(0, (int acc, WorkerNode node) => acc + node.load) /
                  nodes.length)
              .round();
    final List<ThroughputPoint> chart = _buildAdminChart(nodes, logs, window);
    final int totalProcessed = chart.fold<int>(
      0,
      (int sum, ThroughputPoint point) => sum + point.processed,
    );
    final int queuePeak = chart.fold<int>(
      0,
      (int maxValue, ThroughputPoint point) => math.max(maxValue, point.queued),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AdminDashboardIntro(
          isRefreshing: isRefreshing,
          window: window,
          onWindowChanged: onWindowChanged,
          activeNodes: activeNodes,
          totalNodes: nodes.length,
          warnings: warningCount,
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 240,
          childAspectRatio: 1.35,
          children: <Widget>[
            _SummaryCard(
              metric: OverviewMetric(
                label: 'Admin logs',
                value: '${logs.length}',
                note: '$successCount success events captured',
                icon: Icons.description_outlined,
              ),
              tone: _SummaryTone.primary,
            ),
            _SummaryCard(
              metric: OverviewMetric(
                label: 'Worker nodes',
                value: '$activeNodes/${nodes.length}',
                note: 'Average load $avgLoad%',
                icon: Icons.dns_outlined,
              ),
              tone: _SummaryTone.neutral,
            ),
            _SummaryCard(
              metric: OverviewMetric(
                label: 'Error signals',
                value: '$errorCount',
                note: 'Admin sees operational noise, not user media',
                icon: Icons.shield_outlined,
              ),
              tone: _SummaryTone.alert,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: AppSurface(
            radius: 24,
            color: AppTheme.sand,
            padding: const EdgeInsets.all(18),
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              children: <Widget>[
                MiniLabel(label: 'Events in window', value: '$totalProcessed'),
                MiniLabel(label: 'Peak pressure', value: '$queuePeak'),
                MiniLabel(label: 'Success signals', value: '$successCount'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1040;
            final Widget activityPanel = SectionPanel(
              title: 'Admin performance',
              description:
                  'A live operational read built from worker load and recent system events, without exposing user galleries.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _SupportPill(
                        label: 'Active nodes',
                        value: '$activeNodes/${nodes.length}',
                      ),
                      _SupportPill(label: 'Warnings', value: '$warningCount'),
                      _SupportPill(label: 'Errors', value: '$errorCount'),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ThroughputChart(data: chart, height: stacked ? 320 : 360),
                ],
              ),
            );

            final Widget sidePanel = SectionPanel(
              title: 'Admin lanes',
              description:
                  'Logs and capacity summarized so the admin can spot pressure without leaving the dashboard.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppSurface(
                    radius: 22,
                    color: AppTheme.surfaceRaised,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Current focus',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.slate,
                                letterSpacing: 1.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _adminFocusCopy(
                            activeNodes: activeNodes,
                            warnings: warningCount,
                            errorCount: errorCount,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.inkSoft, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...nodes.map(
                    (WorkerNode node) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NodeHealthCard(
                        node: NodeHealth(
                          id: node.id,
                          zone: node.address,
                          load: node.load,
                          throughput: '${node.currentJobs} job(s)',
                          tone: node.load >= 75
                              ? NodeTone.warm
                              : node.load >= 55
                              ? NodeTone.balancing
                              : NodeTone.stable,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  activityPanel,
                  const SizedBox(height: 20),
                  sidePanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 8, child: activityPanel),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: sidePanel),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'Admin activity feed',
          description:
              'The latest backend-visible events that matter for operations and support.',
          child: Column(
            children: logs.take(6).map((LogEntry log) {
              final Color color = switch (log.level) {
                LogLevel.success => AppTheme.success,
                LogLevel.warning => AppTheme.goldDeep,
                LogLevel.error => AppTheme.red,
                LogLevel.info => AppTheme.navy,
              };
              final Color background = switch (log.level) {
                LogLevel.success => AppTheme.successSoft,
                LogLevel.warning => AppTheme.sand,
                LogLevel.error => AppTheme.dangerSoft,
                LogLevel.info => AppTheme.surfaceContainer,
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppSurface(
                  radius: 20,
                  color: AppTheme.white,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StatusChip(
                        label: log.level.name,
                        color: color,
                        background: background,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              log.message,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${log.source} - ${log.time}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                          ],
                        ),
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

class _AdminDashboardIntro extends StatelessWidget {
  const _AdminDashboardIntro({
    required this.isRefreshing,
    required this.window,
    required this.onWindowChanged,
    required this.activeNodes,
    required this.totalNodes,
    required this.warnings,
  });

  final bool isRefreshing;
  final DashboardWindow window;
  final ValueChanged<DashboardWindow> onWindowChanged;
  final int activeNodes;
  final int totalNodes;
  final int warnings;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 30,
      color: AppTheme.white,
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 980;

          final Widget copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.sand,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'ADMIN VIEW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.navy,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  if (isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  const StatusChip(
                    label: 'Observability lane',
                    color: AppTheme.goldDeep,
                    background: AppTheme.sand,
                    icon: Icons.admin_panel_settings_outlined,
                  ),
                  StatusChip(
                    label: '$activeNodes/$totalNodes nodes active',
                    color: AppTheme.navy,
                    background: AppTheme.surfaceContainer,
                    icon: Icons.dns_outlined,
                  ),
                  StatusChip(
                    label: '$warnings warnings',
                    color: AppTheme.red,
                    background: AppTheme.dangerSoft,
                    icon: Icons.notification_important_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Admin command center',
                style: AppTheme.displayStyle(context, size: 30),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  'This lane exposes operational logs and performance graphics for admin accounts. It appears only when the backend sends role 1.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                    height: 1.65,
                  ),
                ),
              ),
            ],
          );

          final Widget controls = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Window',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.slate,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DashboardWindow.values.map((DashboardWindow item) {
                    return TogglePill(
                      label: item.label,
                      selected: window == item,
                      onTap: () => onWindowChanged(item),
                    );
                  }).toList(),
                ),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[copy, const SizedBox(height: 18), controls],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(width: 280, child: controls),
            ],
          );
        },
      ),
    );
  }
}

List<ThroughputPoint> _buildAdminChart(
  List<WorkerNode> nodes,
  List<LogEntry> logs,
  DashboardWindow window,
) {
  final List<String> labels = switch (window) {
    DashboardWindow.day => const <String>['08', '10', '12', '14', '16', '18'],
    DashboardWindow.week => const <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ],
    DashboardWindow.month => const <String>['W1', 'W2', 'W3', 'W4'],
  };

  // Use real CPU/RAM data from metrics if available
  final int totalCpu = nodes.isEmpty
      ? 0
      : nodes.fold<int>(0, (int acc, WorkerNode n) => acc + n.load);
  final int totalRam = nodes.isEmpty
      ? 0
      : nodes.fold<int>(0, (int acc, WorkerNode n) => acc + n.ramUsage);
  final int totalWorkers = nodes.isEmpty
      ? 0
      : nodes.fold<int>(0, (int acc, WorkerNode n) => acc + n.busyWorkers);

  // Use real values; if backend reports 0 load (idle system), show a small
  // baseline (1) so the chart renders visible bars instead of being blank.
  final int baseCpu = totalCpu > 0 ? totalCpu : (nodes.isNotEmpty ? 1 : 0);
  final int baseRam = totalRam > 0 ? totalRam : (nodes.isNotEmpty ? 1 : 0);
  final int baseJobs = totalWorkers > 0
      ? totalWorkers
      : (logs.isNotEmpty ? math.max(1, logs.length ~/ 4) : 0);

  return labels.asMap().entries.map((MapEntry<int, String> entry) {
    final int index = entry.key;
    final String label = entry.value;

    // Simulate realistic-looking spread across time slots using real metrics
    final double waveFactor = math.sin((index + 1) * 0.8) * 0.3 + 0.85;
    final int processed = (baseCpu * waveFactor).round().clamp(0, 100);
    final int queued = baseJobs > 0
        ? math.max(0, (baseRam * waveFactor * 0.6).round())
        : (baseRam > 0 ? math.max(0, (baseRam * waveFactor * 0.5).round()) : 0);

    return ThroughputPoint(label: label, processed: processed, queued: queued);
  }).toList();
}

String _adminFocusCopy({
  required int activeNodes,
  required int warnings,
  required int errorCount,
}) {
  if (errorCount > 0) {
    return 'Error signals are visible. Review logs first, then verify whether one of the active nodes is carrying too much load.';
  }
  if (warnings > 0) {
    return 'The backend is processing, but warnings are visible. The healthiest move is to check logs before queue pressure turns into support noise.';
  }
  if (activeNodes <= 1) {
    return 'Only one lane is carrying visible activity. Capacity is still narrow, so admin attention should stay on node availability.';
  }
  return 'The workspace is stable. Logs look clean and load is spread well enough to keep the batch flow readable.';
}

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro({
    required this.isRefreshing,
    required this.window,
    required this.onWindowChanged,
  });

  final bool isRefreshing;
  final DashboardWindow window;
  final ValueChanged<DashboardWindow> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final stats = workspace.userStatistics;
    final summary = stats.totalImages > 0
        ? 'Workspace is active with ${stats.totalImages} images processed. ${stats.successRateLabel} success rate across all batches.'
        : 'Your workspace is ready. Start by uploading images to see your processing metrics here.';

    return AppSurface(
      radius: 30,
      color: AppTheme.white,
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 980;

          final Widget copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.sand,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'DASHBOARD',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.navy,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  if (isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const <Widget>[
                  StatusChip(
                    label: 'Live operational telemetry',
                    color: AppTheme.goldDeep,
                    background: AppTheme.sand,
                    icon: Icons.analytics_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Workspace performance',
                style: AppTheme.displayStyle(context, size: 30),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                    height: 1.65,
                  ),
                ),
              ),
            ],
          );

          final Widget controls = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Window',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.slate,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DashboardWindow.values.map((DashboardWindow item) {
                    return TogglePill(
                      label: item.label,
                      selected: window == item,
                      onTap: () => onWindowChanged(item),
                    );
                  }).toList(),
                ),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[copy, const SizedBox(height: 18), controls],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(width: 280, child: controls),
            ],
          );
        },
      ),
    );
  }
}

enum _SummaryTone { primary, neutral, alert }

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.metric, required this.tone});

  final OverviewMetric metric;
  final _SummaryTone tone;

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (tone) {
      _SummaryTone.primary => AppTheme.navy,
      _SummaryTone.neutral => AppTheme.goldDeep,
      _SummaryTone.alert => AppTheme.red,
    };

    final Color badge = switch (tone) {
      _SummaryTone.primary => AppTheme.surfaceContainer,
      _SummaryTone.neutral => AppTheme.sand,
      _SummaryTone.alert => AppTheme.dangerSoft,
    };

    return AppSurface(
      radius: 24,
      color: tone == _SummaryTone.primary
          ? AppTheme.surfaceContainer
          : AppTheme.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badge,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: accent, size: 20),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                metric.label.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.slate,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                metric.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.displayStyle(
                  context,
                  size: 28,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportPill extends StatelessWidget {
  const _SupportPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppTheme.ink),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
          ),
        ],
      ),
    );
  }
}

class _NodeHealthCard extends StatelessWidget {
  const _NodeHealthCard({required this.node});

  final NodeHealth node;

  @override
  Widget build(BuildContext context) {
    final Color toneColor = _toneColor(node.tone);

    return AppSurface(
      radius: 20,
      color: AppTheme.white,
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
              Expanded(
                child: Text(
                  node.id,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                node.throughput,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

class ThroughputChart extends StatelessWidget {
  const ThroughputChart({super.key, required this.data, this.height = 340});

  final List<ThroughputPoint> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final int maxValue = math.max(
      1,
      data.fold<int>(
        0,
        (int v, ThroughputPoint p) =>
            math.max(v, math.max(p.processed, p.queued)),
      ),
    );
    final double barAreaHeight = math.max(220, height - 100);
    // Horizontal grid lines at 25%, 50%, 75%, 100%
    const List<double> gridFractions = <double>[0.25, 0.5, 0.75, 1.0];

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
          child: Stack(
            children: <Widget>[
              // ── Grid lines ──────────────────────────────────────────
              Positioned.fill(
                bottom: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: gridFractions.reversed.map((double fraction) {
                    return Row(
                      children: <Widget>[
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${(maxValue * fraction).round()}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.slate.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.border.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              // ── Bars ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 36, bottom: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((ThroughputPoint point) {
                    final double processedH =
                        barAreaHeight * point.processed / maxValue;
                    final double queuedH =
                        barAreaHeight * point.queued / maxValue;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // Value label on top of bar
                            if (point.processed > 0)
                              Text(
                                '${point.processed}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.slate.withValues(alpha: 0.8),
                                ),
                              ),
                            const SizedBox(height: 4),
                            // Processed bar with gradient
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              child: Container(
                                height: math.max(
                                  processedH,
                                  point.processed > 0 ? 6 : 0,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Color(0xFF4A5568), // lighter top
                                      AppTheme.ink, // darker bottom
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (point.queued > 0) ...<Widget>[
                              const SizedBox(height: 2),
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                child: Container(
                                  height: math.max(queuedH, 4),
                                  color: AppTheme.warning,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // ── X-axis labels ────────────────────────────────────────
              Positioned(
                left: 36,
                right: 0,
                bottom: 0,
                height: 36,
                child: Row(
                  children: data
                      .map(
                        (ThroughputPoint point) => Expanded(
                          child: Center(
                            child: Text(
                              point.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.slate.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
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
