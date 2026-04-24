import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/admin/domain/admin_audit_log.dart';
import 'package:imageflow_flutter/features/logs/presentation/log_level_visuals.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final List<AdminAuditLog> systemLogs = workspace.adminLogs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PageIntro(
          kicker: 'Observability',
          title: 'System logs',
          description:
              'Read the backend admin log feed without exposing user-owned media.',
          actions: OutlinedButton.icon(
            onPressed: () => workspace.refreshAdminLogs(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh Logs'),
          ),
        ),
        const SizedBox(height: 20),
        AppSurface(
          radius: AppTheme.radii.xl,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              StatusChip(
                label: 'Backend endpoint',
                color: AppTheme.goldDeep,
                background: AppTheme.sand,
                icon: Icons.link_rounded,
              ),
              StatusChip(
                label: '${systemLogs.length} events',
                color: AppTheme.navy,
                background: AppTheme.surfaceContainer,
                icon: Icons.description_outlined,
              ),
              if ((workspace.adminLogImageUuid ?? '').isNotEmpty)
                StatusChip(
                  label: 'Image log lookup active',
                  color: AppTheme.slate,
                  background: AppTheme.surfaceContainer,
                  icon: Icons.image_search_outlined,
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (systemLogs.isEmpty)
          const AppSurface(
            child: Text(
              'The backend did not return admin logs for the current image lookup.',
            ),
          )
        else
          SectionPanel(
            title: 'Recent Logs',
            description:
                'Live events returned by the admin log endpoint.',
            child: Column(
              children: systemLogs.map((AdminAuditLog log) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radii.lg),
                    border: Border.all(color: AppTheme.outlineVariant),
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
                                  _logTimestamp(log),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                ),
                                StatusChip(
                                  label: logLevelLabel(log.level),
                                  color: logLevelColor(log.level),
                                  background: logLevelBackground(log.level),
                                ),
                                const StatusChip(
                                  label: 'admin',
                                  color: AppTheme.slate,
                                  background: AppTheme.surfaceContainer,
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

String _logTimestamp(AdminAuditLog log) {
  final String createdAt = log.createdAt.trim();
  if (createdAt.isEmpty || createdAt == '0001-01-01T00:00:00Z') {
    return 'No timestamp';
  }
  return createdAt;
}
