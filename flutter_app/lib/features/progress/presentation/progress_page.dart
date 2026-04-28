import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/results/domain/batch_gallery_image.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refresh();
      if (mounted) {
        _pollTimer = Timer.periodic(
          const Duration(seconds: 3),
          (_) => _refresh(),
        );
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final workspace = WorkspaceScope.of(context);
    try {
      await workspace.refreshLatestBatchImages(notify: false);
      if (!mounted) {
        return;
      }
      setState(() {});
      final batch = workspace.latestBatch;
      if (batch != null &&
          batch.fileCount > 0 &&
          workspace.latestBatchImages.length >= batch.fileCount) {
        _pollTimer?.cancel();
      }
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final latestBatch = workspace.latestBatch;
    final List<BatchGalleryImage> images = workspace.latestBatchImages;
    final int totalFiles = latestBatch?.fileCount ?? 0;
    final int completed = images
        .where(
          (BatchGalleryImage image) => image.isProcessed && image.hasResult,
        )
        .length
        .clamp(0, totalFiles == 0 ? images.length : totalFiles);
    final int failed = images
        .where(
          (BatchGalleryImage image) =>
              image.status.trim().toUpperCase() == 'FAILED',
        )
        .length;
    final int processing = images
        .where(
          (BatchGalleryImage image) =>
              image.status.trim().toUpperCase() != 'FAILED' &&
              !(image.isProcessed && image.hasResult),
        )
        .length;
    final int queued = math.max(
      0,
      totalFiles - completed - failed - processing,
    );
    final double progress = totalFiles == 0
        ? 0
        : (completed / totalFiles).clamp(0, 1);
    final bool finished =
        totalFiles > 0 &&
        completed + failed >= totalFiles &&
        processing == 0 &&
        queued == 0;

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
                    finished ? 'Batch completed' : 'Processing Progress',
                    style: AppTheme.displayStyle(context, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Batch ID: ${latestBatch?.requestId ?? 'pending'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            if (finished)
              FilledButton(
                onPressed: () => widget.onNavigate(AppPage.results),
                child: const Text('View Results'),
              ),
          ],
        ),
        const SizedBox(height: 20),
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Overall Progress',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          totalFiles == 0
                              ? 'No batch has been submitted yet.'
                              : finished
                              ? 'All $totalFiles images already reached the gallery.'
                              : 'Polling the backend gallery for completed outputs in this batch.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${(progress * 100).round()}%',
                        style: AppTheme.displayStyle(context, size: 32),
                      ),
                      Text(
                        '$completed of $totalFiles completed',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SignalProgressBar(
                value: progress,
                pulse: !finished,
                completed: completed,
                total: totalFiles,
              ),
              const SizedBox(height: 18),
              AdaptiveGrid(
                minItemWidth: 180,
                childAspectRatio: 1.45,
                children: <Widget>[
                  _StatusStatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Completed',
                    value: '$completed',
                    color: AppTheme.statusGreen,
                    background: AppTheme.sand,
                  ),
                  _StatusStatCard(
                    icon: Icons.autorenew_rounded,
                    label: 'Processing',
                    value: '$processing',
                    color: AppTheme.red,
                    background: AppTheme.sand,
                  ),
                  _StatusStatCard(
                    icon: Icons.schedule_outlined,
                    label: 'Queued',
                    value: '$queued',
                    color: AppTheme.slate,
                    background: AppTheme.sand,
                  ),
                  _StatusStatCard(
                    icon: Icons.cancel_outlined,
                    label: 'Failed',
                    value: '$failed',
                    color: AppTheme.danger,
                    background: AppTheme.dangerSoft,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (images.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          SectionPanel(
            title: 'Batch gallery',
            description:
                'This view reflects the real gallery payload from the backend, including placeholders for files that are still processing.',
            child: AdaptiveGrid(
              minItemWidth: 200,
              childAspectRatio: 0.88,
              spacing: 14,
              children: images.map((BatchGalleryImage image) {
                final bool hasPreview =
                    image.hasResult &&
                    workspace.isReachablePreviewUrl(image.resultUrl);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppTheme.outlineVariant),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasPreview
                            ? Image.network(
                                image.resultUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                headers: workspace.authHeaders,
                                errorBuilder: (_, __, ___) =>
                                    _ProgressImagePlaceholder(
                                      status: image.status,
                                    ),
                              )
                            : _ProgressImagePlaceholder(status: image.status),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      image.originalName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${image.status} • ${image.nodeId.isEmpty ? "-" : image.nodeId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProgressImagePlaceholder extends StatelessWidget {
  const _ProgressImagePlaceholder({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final String normalized = status.trim().toUpperCase();
    final IconData icon = switch (normalized) {
      'FAILED' => Icons.error_outline_rounded,
      'PROCESSING' => Icons.autorenew_rounded,
      'COMPLETED' || 'CONVERTED' => Icons.image_outlined,
      _ => Icons.hourglass_top_rounded,
    };
    final String label = switch (normalized) {
      'FAILED' => 'Failed',
      'PROCESSING' => 'Processing',
      'RECEIVED' => 'Received',
      'COMPLETED' || 'CONVERTED' => 'No file',
      _ => normalized.isEmpty ? 'Pending' : normalized,
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 32, color: AppTheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SignalProgressBar extends StatefulWidget {
  const _SignalProgressBar({
    required this.value,
    required this.pulse,
    required this.completed,
    required this.total,
  });

  final double value;
  final bool pulse;
  final int completed;
  final int total;

  @override
  State<_SignalProgressBar> createState() => _SignalProgressBarState();
}

class _SignalProgressBarState extends State<_SignalProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double value = widget.value.clamp(0, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 18,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(color: AppTheme.border),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, _) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: <Color>[
                              AppTheme.goldDeep,
                              AppTheme.secondary,
                              widget.pulse ? AppTheme.ink : AppTheme.success,
                            ],
                            stops: <double>[
                              0,
                              0.55,
                              widget.pulse
                                  ? (0.75 + (_controller.value * 0.2))
                                  : 1,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.total == 0
              ? 'Waiting for a batch.'
              : '${widget.completed} of ${widget.total} outputs already visible in gallery.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
        ),
      ],
    );
  }
}

class _StatusStatCard extends StatelessWidget {
  const _StatusStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTheme.displayStyle(context, size: 28, color: color),
          ),
        ],
      ),
    );
  }
}
