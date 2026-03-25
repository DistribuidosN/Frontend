import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late final Timer _timer;
  double _progress = 45;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_progress >= 100) {
          timer.cancel();
        } else {
          _progress += 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int completed = ((_progress / 100) * 24).round().clamp(0, 24);
    final int processing = _progress < 100 ? math.min(6, 24 - completed) : 0;
    final int queued = _progress < 100 ? math.max(0, 24 - completed - 6) : 0;

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
                    'Processing Progress',
                    style: AppTheme.displayStyle(context, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request ID: req-4522',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            if (_progress >= 100)
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
                          'Processing 24 images across 8 worker nodes',
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
                        '${_progress.round()}%',
                        style: AppTheme.displayStyle(context, size: 32),
                      ),
                      Text(
                        '$completed of 24 completed',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProgressLine(value: _progress / 100, color: AppTheme.ink),
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
                    value: '0',
                    color: AppTheme.danger,
                    background: AppTheme.dangerSoft,
                  ),
                ],
              ),
            ],
          ),
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
