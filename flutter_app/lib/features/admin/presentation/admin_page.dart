import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/admin/domain/admin_audit_log.dart';
import 'package:imageflow_flutter/features/admin/domain/admin_node_metric.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nodeIdController = TextEditingController();
  final TextEditingController _imageUuidController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final workspace = WorkspaceScope.of(context);
    _nodeIdController.text = workspace.adminMetricNodeId;
    final String initialImageUuid = workspace.adminLogImageUuid?.trim().isNotEmpty == true
        ? workspace.adminLogImageUuid!.trim()
        : workspace.latestBatchImages.isNotEmpty
        ? workspace.latestBatchImages.first.imageUuid.trim()
        : '';
    _imageUuidController.text = initialImageUuid;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _refreshAll();
    });
  }

  @override
  void dispose() {
    _nodeIdController.dispose();
    _imageUuidController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    final workspace = WorkspaceScope.of(context);
    final String nodeId = _nodeIdController.text.trim();
    final String imageUuid = _imageUuidController.text.trim();

    try {
      await workspace.refreshAdminMetrics(
        nodeId: nodeId.isEmpty ? null : nodeId,
      );
    } catch (_) {}

    try {
      await workspace.refreshAdminLogs(
        imageUuid: imageUuid.isEmpty ? null : imageUuid,
      );
    } catch (_) {}
  }

  Future<void> _refreshMetrics() async {
    final workspace = WorkspaceScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final String nodeId = _nodeIdController.text.trim();
    try {
      await workspace.refreshAdminMetrics(
        nodeId: nodeId.isEmpty ? null : nodeId,
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not refresh node metrics: $error')),
      );
    }
  }

  Future<void> _refreshLogs() async {
    final workspace = WorkspaceScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final String imageUuid = _imageUuidController.text.trim();
    try {
      await workspace.refreshAdminLogs(
        imageUuid: imageUuid.isEmpty ? null : imageUuid,
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not refresh admin logs: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final List<AdminNodeMetric> nodes = workspace.adminNodeMetrics;
    final List<AdminAuditLog> logs = workspace.adminLogs;
    final int activeNodes = nodes.where((AdminNodeMetric node) => node.active).length;
    final int errorLogs = logs.where((AdminAuditLog log) => log.level == LogLevel.error).length;
    final int warningLogs = logs.where((AdminAuditLog log) => log.level == LogLevel.warning).length;
    final int successLogs = logs.where((AdminAuditLog log) => log.level == LogLevel.success).length;
    final int infoLogs = logs.where((AdminAuditLog log) => log.level == LogLevel.info).length;
    final int avgLoad = nodes.isEmpty
        ? 0
        : (nodes.fold<int>(0, (int acc, AdminNodeMetric node) => acc + node.load) / nodes.length)
            .round();
    final int totalJobs = nodes.fold<int>(0, (int acc, AdminNodeMetric node) => acc + node.currentJobs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PageIntro(
          kicker: 'Admin',
          title: 'Admin command center',
          description:
              'Inspect workspace health, recent incidents, node pressure and operational logs without browsing user photos or request content.',
          actions: StatusChip(
            label: 'Observability lane',
            color: AppTheme.goldDeep,
            background: AppTheme.sand,
            icon: Icons.verified_user_outlined,
          ),
        ),
        const SizedBox(height: 20),
        AppSurface(
          radius: AppTheme.radii.xl,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              FilterField(
                icon: Icons.dns_outlined,
                label: 'Node ID for metrics lookup',
                width: 320,
                controller: _nodeIdController,
                onSubmitted: (_) => _refreshMetrics(),
              ),
              FilterField(
                icon: Icons.image_search_outlined,
                label: 'Image UUID for log lookup',
                width: 360,
                controller: _imageUuidController,
                onSubmitted: (_) => _refreshLogs(),
              ),
              ChipFilter(
                icon: Icons.refresh_rounded,
                label: 'Refresh all',
                onPressed: _refreshAll,
              ),
              ChipFilter(
                icon: Icons.history_rounded,
                label: 'Use latest batch',
                onPressed: workspace.latestBatchImages.isNotEmpty
                    ? () {
                        setState(() {
                          _imageUuidController.text =
                              workspace.latestBatchImages.first.imageUuid.trim();
                        });
                        _refreshLogs();
                      }
                    : null,
              ),
              ChipFilter(
                icon: Icons.restore_rounded,
                label: 'Default node',
                onPressed: () {
                  setState(() {
                    _nodeIdController.text = workspace.adminMetricNodeId;
                  });
                  _refreshMetrics();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 220,
          childAspectRatio: 1.22,
          children: <Widget>[
            SummaryMetricCard(
              label: 'Active nodes',
              value: nodes.isEmpty ? '--' : '$activeNodes/${nodes.length}',
              color: AppTheme.ink,
            ),
            SummaryMetricCard(
              label: 'Average load',
              value: nodes.isEmpty ? '--' : '$avgLoad%',
              color: AppTheme.goldDeep,
            ),
            SummaryMetricCard(
              label: 'Warnings',
              value: '$warningLogs',
              color: AppTheme.orange,
            ),
            SummaryMetricCard(
              label: 'Errors',
              value: '$errorLogs',
              color: AppTheme.red,
            ),
          ],
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 280,
          childAspectRatio: 1.02,
          children: <Widget>[
            _AdminActionCard(
              title: 'Logs',
              description: 'Review auth, batch and infrastructure events.',
              value: '${logs.length} events',
              icon: Icons.description_outlined,
              onTap: () => widget.onNavigate(AppPage.logs),
            ),
            _AdminActionCard(
              title: 'Node metrics',
              description: 'Inspect worker load, active jobs and heartbeats.',
              value: nodes.isEmpty ? 'No backend data yet' : '$totalJobs active jobs',
              icon: Icons.dns_outlined,
              onTap: () => widget.onNavigate(AppPage.nodes),
            ),
            _AdminActionCard(
              title: 'System posture',
              description: 'Stay on health, capacity and event monitoring.',
              value: '$successLogs success signals',
              icon: Icons.shield_outlined,
              onTap: () => widget.onNavigate(AppPage.admin),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1040;
            final Widget metricsPanel = SectionPanel(
              title: 'Performance snapshot',
              description:
                  'Admin-facing read of worker pressure and log severity using backend data only.',
              action: StatusChip(
                label: errorLogs > 0
                    ? '$errorLogs active errors'
                    : '$warningLogs warnings',
                color: errorLogs > 0 ? AppTheme.red : AppTheme.goldDeep,
                background: errorLogs > 0 ? AppTheme.dangerSoft : AppTheme.sand,
              ),
              child: Column(
                children: <Widget>[
                  if (nodes.isEmpty)
                    _BackendEmptyCard(
                      message:
                          'The backend did not return node metrics for ${workspace.adminMetricNodeId}.',
                    )
                  else
                    _MetricBarCard(
                      title: 'Node load distribution',
                      subtitle:
                          'How much each worker is carrying right now in the admin view.',
                      items: nodes.map((AdminNodeMetric node) {
                        return _BarMetric(
                          label: node.id,
                          detail: '${node.currentJobs} job(s)',
                          value: node.load,
                          tone: node.load >= 80
                              ? AppTheme.red
                              : node.load >= 60
                              ? AppTheme.goldDeep
                              : AppTheme.ink,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  _MetricBarCard(
                    title: 'Operational signals',
                    subtitle:
                        'A direct severity split based on the backend admin log feed.',
                    items: <_BarMetric>[
                      _BarMetric(
                        label: 'Warnings',
                        detail: 'Needs review',
                        value: warningLogs,
                        tone: AppTheme.orange,
                      ),
                      _BarMetric(
                        label: 'Errors',
                        detail: 'Immediate attention',
                        value: errorLogs,
                        tone: AppTheme.red,
                      ),
                      _BarMetric(
                        label: 'Info signals',
                        detail: 'Background system events',
                        value: infoLogs,
                        tone: AppTheme.navy,
                      ),
                    ],
                  ),
                ],
              ),
            );

            final Widget feedPanel = SectionPanel(
              title: 'Recent admin feed',
              description:
                  'The latest processing events returned by the backend admin log endpoint.',
              child: logs.isEmpty
                  ? const _BackendEmptyCard(
                      message:
                          'No admin events were returned by the backend for the current log lookup.',
                    )
                  : Column(
                      children: logs.take(6).map((AdminAuditLog log) {
                        final Color tone = switch (log.level) {
                          LogLevel.success => AppTheme.success,
                          LogLevel.info => AppTheme.navy,
                          LogLevel.warning => AppTheme.orange,
                          LogLevel.error => AppTheme.red,
                        };
                        final Color bg = switch (log.level) {
                          LogLevel.success => AppTheme.successSoft,
                          LogLevel.info => AppTheme.surfaceContainer,
                          LogLevel.warning => AppTheme.sand,
                          LogLevel.error => AppTheme.dangerSoft,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppSurface(
                            radius: 18,
                            color: AppTheme.white,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                StatusChip(
                                  label: log.level.name,
                                  color: tone,
                                  background: bg,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        log.message,
                                        style:
                                            Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _adminLogMeta(log),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
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
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  metricsPanel,
                  const SizedBox(height: 20),
                  feedPanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 7, child: metricsPanel),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: feedPanel),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({
    required this.title,
    required this.description,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 24,
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.navy, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.slate,
                  height: 1.45,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.ink,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onTap,
                child: const Text('Open'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBarCard extends StatelessWidget {
  const _MetricBarCard({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<_BarMetric> items;

  @override
  Widget build(BuildContext context) {
    final int maxValue = math.max(
      1,
      items.fold<int>(0, (int acc, _BarMetric item) => math.max(acc, item.value)),
    );

    return AppSurface(
      radius: 22,
      color: AppTheme.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.slate,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 18),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      Text(
                        '${item.value}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.detail,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.slate,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProgressLine(
                    value: item.value / maxValue,
                    color: item.tone,
                    background: AppTheme.sand,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BackendEmptyCard extends StatelessWidget {
  const _BackendEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 20,
      color: AppTheme.white,
      padding: const EdgeInsets.all(18),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.slate,
            ),
      ),
    );
  }
}

class _BarMetric {
  const _BarMetric({
    required this.label,
    required this.detail,
    required this.value,
    required this.tone,
  });

  final String label;
  final String detail;
  final int value;
  final Color tone;
}

String _adminLogMeta(AdminAuditLog log) {
  final String timestamp = log.createdAt.trim();
  if (timestamp.isEmpty || timestamp == '0001-01-01T00:00:00Z') {
    return 'admin log event';
  }
  return 'admin - $timestamp';
}
