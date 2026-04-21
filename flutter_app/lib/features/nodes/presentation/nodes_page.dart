import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/nodes/domain/worker_node.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

enum _NodeFilter { all, active, inactive }

class NodesPage extends StatefulWidget {
  const NodesPage({super.key});

  @override
  State<NodesPage> createState() => _NodesPageState();
}

class _NodesPageState extends State<NodesPage> {
  _NodeFilter _filter = _NodeFilter.all;

  @override
  Widget build(BuildContext context) {
    final List<WorkerNode> workerNodes = WorkspaceScope.of(context).workerNodes;
    final int activeCount = workerNodes
        .where((WorkerNode node) => node.active)
        .length;
    final int avgLoad =
        (workerNodes.fold<int>(
                  0,
                  (int acc, WorkerNode node) => acc + node.load,
                ) /
                workerNodes.length)
            .round();
    final int totalJobs = workerNodes.fold<int>(
      0,
      (int acc, WorkerNode node) => acc + node.currentJobs,
    );
    final List<WorkerNode> filteredNodes = switch (_filter) {
      _NodeFilter.all => workerNodes,
      _NodeFilter.active =>
        workerNodes.where((WorkerNode node) => node.active).toList(),
      _NodeFilter.inactive =>
        workerNodes.where((WorkerNode node) => !node.active).toList(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Worker Nodes',
                    style: AppTheme.displayStyle(context, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor and manage your distributed worker cluster',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(onPressed: () {}, child: const Text('Add Node')),
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Worker Nodes',
                        style: AppTheme.displayStyle(context, size: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor and manage your distributed worker cluster',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                ),
                FilledButton(onPressed: () {}, child: const Text('Add Node')),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 220,
          childAspectRatio: 1.22,
          children: <Widget>[
            _NodesSummaryCard(
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppTheme.success,
              iconBackground: AppTheme.successSoft,
              label: 'Active Nodes',
              value: '$activeCount',
              suffix: '/${workerNodes.length}',
            ),
            _NodesSummaryCard(
              icon: Icons.monitor_heart_outlined,
              iconColor: AppTheme.ink,
              iconBackground: AppTheme.sand,
              label: 'Average Load',
              value: '$avgLoad%',
            ),
            _NodesSummaryCard(
              icon: Icons.dns_outlined,
              iconColor: AppTheme.goldDeep,
              iconBackground: AppTheme.warningSoft,
              label: 'Active Jobs',
              value: '$totalJobs',
            ),
            _NodesSummaryCard(
              icon: Icons.schedule_outlined,
              iconColor: AppTheme.red,
              iconBackground: AppTheme.infoSoft,
              label: 'Total Processed',
              value: '24.5K',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _NodeFilterButton(
              label: 'All Nodes (${workerNodes.length})',
              selected: _filter == _NodeFilter.all,
              onTap: () => setState(() => _filter = _NodeFilter.all),
            ),
            _NodeFilterButton(
              label: 'Active ($activeCount)',
              selected: _filter == _NodeFilter.active,
              onTap: () => setState(() => _filter = _NodeFilter.active),
            ),
            _NodeFilterButton(
              label: 'Inactive (${workerNodes.length - activeCount})',
              selected: _filter == _NodeFilter.inactive,
              onTap: () => setState(() => _filter = _NodeFilter.inactive),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AdaptiveGrid(
          minItemWidth: 420,
          childAspectRatio: 1.3,
          children: filteredNodes.map((WorkerNode node) {
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
              padding: const EdgeInsets.all(24),
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
                              node.address,
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
                          width: 86,
                          child: MiniLabel(label: 'Uptime', value: node.uptime),
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
                            'Last heartbeat: ${node.lastHeartbeat}',
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

class _NodesSummaryCard extends StatelessWidget {
  const _NodesSummaryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.suffix,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 16,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact =
              constraints.maxWidth < 220 || constraints.maxHeight < 150;
          final double contentPadding = compact ? 16 : 24;
          final double iconBox = compact ? 34 : 40;
          final double iconSize = compact ? 18 : 20;
          final double titleGap = compact ? 10 : 14;
          final double valueGap = compact ? 4 : 6;

          return Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: iconBox,
                  height: iconBox,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(compact ? 11 : 12),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: Icon(icon, size: iconSize + 1, color: iconColor),
                ),
                SizedBox(height: titleGap),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                ),
                SizedBox(height: valueGap),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: AppTheme.displayStyle(
                            context,
                            size: compact ? 24 : 30,
                            height: 1.0,
                          ),
                          children: <InlineSpan>[
                            TextSpan(text: value),
                            if (suffix != null)
                              TextSpan(
                                text: suffix,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppTheme.slate,
                                      fontSize: compact ? 14 : null,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NodeFilterButton extends StatelessWidget {
  const _NodeFilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.navy.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[AppTheme.gold, AppTheme.goldDeep],
                  )
                : null,
            color: selected ? null : AppTheme.sand,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.navy.withValues(alpha: 0)
                  : AppTheme.border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? AppTheme.ink : AppTheme.slate,
            ),
          ),
        ),
      ),
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
