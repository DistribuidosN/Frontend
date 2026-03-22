import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/logs/data/system_logs_mock_data.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/logs/presentation/log_level_visuals.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

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
                    'System Logs',
                    style: AppTheme.displayStyle(context, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor processing events and system activity',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Export Logs'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppSurface(
          child: Column(
            children: <Widget>[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const <Widget>[
                  FilterField(
                    icon: Icons.search_rounded,
                    label: 'Search logs...',
                  ),
                  ChipFilter(
                    icon: Icons.filter_alt_outlined,
                    label: 'All Levels',
                  ),
                  ChipFilter(icon: Icons.hub_outlined, label: 'All Sources'),
                  ChipFilter(icon: Icons.schedule_outlined, label: 'Last Hour'),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  TogglePill(
                    label: 'All (${systemLogs.length})',
                    selected: true,
                    onTap: () {},
                  ),
                  TogglePill(
                    label: 'Errors (1)',
                    selected: false,
                    onTap: () {},
                  ),
                  TogglePill(
                    label: 'Warnings (1)',
                    selected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'Recent Logs',
          child: Column(
            children: systemLogs.map((LogEntry log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      logLevelIcon(log.level),
                      color: logLevelColor(log.level),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                log.time,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.slate),
                              ),
                              StatusChip(
                                label: logLevelLabel(log.level),
                                color: logLevelColor(log.level),
                                background: logLevelBackground(log.level),
                              ),
                              StatusChip(
                                label: log.source,
                                color: AppTheme.slate,
                                background: AppTheme.canvasSoft,
                              ),
                              if (log.job != '-')
                                StatusChip(
                                  label: log.job,
                                  color: AppTheme.ink,
                                  background: Colors.white,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            log.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
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
