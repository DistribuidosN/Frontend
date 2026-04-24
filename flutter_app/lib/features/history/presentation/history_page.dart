import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/history/domain/history_request.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final List<HistoryRequest> historyRequests = workspace.historyRequests;

    return AppSurface(
      radius: 32,
      color: AppTheme.white,
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Processing History',
              style: AppTheme.displayStyle(context, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              'View all previous image processing requests',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
            ),
            const SizedBox(height: 20),
            AppSurface(
              color: AppTheme.surfaceRaised,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const <Widget>[
                  FilterField(
                    icon: Icons.search_rounded,
                    label: 'Search by request ID, transformations...',
                    width: 440,
                  ),
                  ChipFilter(
                    icon: Icons.date_range_outlined,
                    label: 'Date Range',
                  ),
                  ChipFilter(
                    icon: Icons.filter_alt_outlined,
                    label: 'Filters',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: workspace.isAuthenticated
                    ? () => workspace.refreshHistory()
                    : null,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh history'),
              ),
            ),
            const SizedBox(height: 20),
            if (historyRequests.isEmpty)
              const AppSurface(
                color: AppTheme.surfaceRaised,
                child: Text(
                  'No remote batches are loaded yet. Submit one from Upload or refresh the backend history.',
                ),
              )
            else
              Column(
                children: historyRequests.map((HistoryRequest request) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppSurface(
                      padding: const EdgeInsets.all(18),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final bool compact = constraints.maxWidth < 1020;
                          final Widget status = StatusChip(
                            label: request.status == RequestStatus.completed
                                ? 'completed'
                                : 'pending',
                            color: request.status == RequestStatus.completed
                                ? AppTheme.statusGreen
                                : AppTheme.goldDeep,
                            background:
                                request.status == RequestStatus.completed
                                ? AppTheme.sand
                                : AppTheme.surfaceContainer,
                          );
                          final Widget idColumn = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  await workspace.selectHistoryBatch(request.id);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  onNavigate(AppPage.results);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  request.id,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppTheme.goldDeep),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request.date,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.slate),
                              ),
                            ],
                          );
                          final List<String> previewTransforms = request
                              .transforms
                              .take(3)
                              .toList();
                          final Widget transforms = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radii.sm,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.outlineVariant,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  size: 14,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: RichText(
                                  maxLines: compact ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: 'Source: ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      TextSpan(
                                        text: previewTransforms.join(' • '),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppTheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                          final Widget actions = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SmallIconButton(
                                icon: Icons.visibility_outlined,
                                onTap: () async {
                                  await workspace.selectHistoryBatch(request.id);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  onNavigate(AppPage.results);
                                },
                              ),
                              const SizedBox(width: 8),
                              SmallIconButton(
                                icon: Icons.download_rounded,
                                onTap: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  try {
                                    await workspace.selectHistoryBatch(request.id);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    final String location = await workspace
                                        .downloadLatestBatchArchive();
                                    if (!context.mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Archive saved to $location',
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(error.toString()),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );

                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(child: idColumn),
                                    status,
                                    const SizedBox(width: 10),
                                    actions,
                                  ],
                                ),
                                const SizedBox(height: 14),
                                transforms,
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    Text(
                                      request.images > 0
                                          ? '${request.images} images'
                                          : 'Images pending sync',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppTheme.slate),
                                    ),
                                    Text(
                                      request.duration,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppTheme.slate),
                                    ),
                                    Text(
                                      request.nodes > 0
                                          ? '${request.nodes} nodes'
                                          : 'Node count unavailable',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppTheme.slate),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: <Widget>[
                              Expanded(flex: 2, child: idColumn),
                              Expanded(
                                child: Text(
                                  request.images > 0 ? '${request.images}' : '--',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              Expanded(flex: 2, child: transforms),
                              Expanded(
                                child: Text(
                                  request.duration,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.slate),
                                ),
                              ),
                              status,
                              const SizedBox(width: 16),
                              actions,
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
