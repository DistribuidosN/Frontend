import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/history/data/history_mock_data.dart';
import 'package:imageflow_flutter/features/history/domain/history_request.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const <Widget>[
              FilterField(
                icon: Icons.search_rounded,
                label: 'Search by request ID, transformations...',
              ),
              ChipFilter(icon: Icons.date_range_outlined, label: 'Date Range'),
              ChipFilter(icon: Icons.filter_alt_outlined, label: 'Filters'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: historyRequests.map((HistoryRequest request) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSurface(
                padding: const EdgeInsets.all(18),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool compact = constraints.maxWidth < 1020;
                    final Widget status = StatusChip(
                      label: request.status == RequestStatus.completed
                          ? 'completed'
                          : 'failed',
                      color: request.status == RequestStatus.completed
                          ? AppTheme.statusGreen
                          : AppTheme.danger,
                      background: request.status == RequestStatus.completed
                          ? AppTheme.sand
                          : AppTheme.dangerSoft,
                    );
                    final Widget idColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => onNavigate(AppPage.requestDetail),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    final Widget transforms = Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: request.transforms
                          .take(2)
                          .map(
                            (String transform) => StatusChip(
                              label: transform,
                              color: AppTheme.ink,
                              background: AppTheme.sand,
                            ),
                          )
                          .toList(),
                    );
                    final Widget actions = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SmallIconButton(
                          icon: Icons.visibility_outlined,
                          onTap: () => onNavigate(AppPage.requestDetail),
                        ),
                        if (request.status ==
                            RequestStatus.completed) ...<Widget>[
                          const SizedBox(width: 8),
                          SmallIconButton(
                            icon: Icons.download_rounded,
                            onTap: () {},
                          ),
                        ],
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
                                '${request.images} images',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.slate),
                              ),
                              Text(
                                request.duration,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.slate),
                              ),
                              Text(
                                '${request.nodes} nodes',
                                style: Theme.of(context).textTheme.bodySmall
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
                            '${request.images}',
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
    );
  }
}
