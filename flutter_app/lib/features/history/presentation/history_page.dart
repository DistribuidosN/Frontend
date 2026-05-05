import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/history/domain/history_request.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  _HistoryStatusFilter _statusFilter = _HistoryStatusFilter.all;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final List<DateTime> dates = WorkspaceScope.of(context).historyRequests
        .map((HistoryRequest request) => request.parsedDate)
        .whereType<DateTime>()
        .toList();

    // Siempre abrimos un rango amplio: desde el batch más antiguo (o -365 días)
    // hasta hoy +1 día. Esto evita que el picker falle cuando hay 1 solo batch.
    final DateTime earliest = dates.isEmpty
        ? DateTime.now().subtract(const Duration(days: 365))
        : dates.reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b)
            .subtract(const Duration(days: 1));
    final DateTime latest = DateTime.now().add(const Duration(days: 1));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateUtils.dateOnly(earliest),
      lastDate: DateUtils.dateOnly(latest),
      initialDateRange: _dateRange,
      helpText: 'Filter by date range',
    );
    if (!mounted) return;
    setState(() => _dateRange = picked);
  }

  bool _matchesSearch(HistoryRequest request) {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    final String haystack = <String>[
      request.id,
      request.date,
      request.duration,
      request.status.name,
      request.images.toString(),
      request.nodes.toString(),
      request.transforms.join(' '),
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  bool _matchesStatus(HistoryRequest request) {
    return switch (_statusFilter) {
      _HistoryStatusFilter.all => true,
      _HistoryStatusFilter.completed => request.status == RequestStatus.completed,
      _HistoryStatusFilter.processing => request.status == RequestStatus.processing,
      _HistoryStatusFilter.received => request.status == RequestStatus.received,
      _HistoryStatusFilter.pending => request.status == RequestStatus.pending,
      _HistoryStatusFilter.failed => request.status == RequestStatus.failed,
    };
  }

  bool _matchesDateRange(HistoryRequest request) {
    if (_dateRange == null) {
      return true;
    }
    final DateTime? parsed = request.parsedDate;
    if (parsed == null) {
      return false;
    }
    final DateTime start = DateUtils.dateOnly(_dateRange!.start);
    final DateTime end = DateUtils.dateOnly(_dateRange!.end)
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));
    return !parsed.isBefore(start) && !parsed.isAfter(end);
  }

  Future<void> _refreshHistory(BuildContext context) async {
    final workspace = WorkspaceScope.of(context);
    await workspace.refreshHistory();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = _HistoryStatusFilter.all;
      _dateRange = null;
    });
  }

  String _rangeLabel() {
    if (_dateRange == null) {
      return 'Date Range';
    }
    final DateTime start = _dateRange!.start;
    final DateTime end = _dateRange!.end;
    return '${_shortDate(start)} - ${_shortDate(end)}';
  }

  String _shortDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final List<HistoryRequest> historyRequests = workspace.historyRequests
        .where(_matchesSearch)
        .where(_matchesStatus)
        .where(_matchesDateRange)
        .toList();

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
              'Search by request ID, transform stack, status or date.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                  ),
            ),
            const SizedBox(height: 20),
            AppSurface(
              color: AppTheme.surfaceRaised,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  FilterField(
                    icon: Icons.search_rounded,
                    label: 'Search by request ID, transformations...',
                    width: 440,
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  ChipFilter(
                    icon: Icons.date_range_outlined,
                    label: _rangeLabel(),
                    selected: _dateRange != null,
                    onPressed: () => _pickDateRange(context),
                  ),
                  ChipFilter(
                    icon: Icons.filter_alt_outlined,
                    label: 'Clear filters',
                    onPressed: _clearFilters,
                    selected: false,
                  ),
                  ChipFilter(
                    icon: Icons.refresh_rounded,
                    label: 'Refresh history',
                    onPressed: workspace.isAuthenticated
                        ? () => _refreshHistory(context)
                        : null,
                    selected: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _StatusToggle(
                  label: 'All',
                  selected: _statusFilter == _HistoryStatusFilter.all,
                  onTap: () => setState(
                    () => _statusFilter = _HistoryStatusFilter.all,
                  ),
                ),
                _StatusToggle(
                  label: 'Completed',
                  selected: _statusFilter == _HistoryStatusFilter.completed,
                  onTap: () => setState(
                    () => _statusFilter = _HistoryStatusFilter.completed,
                  ),
                ),
                _StatusToggle(
                  label: 'Processing',
                  selected: _statusFilter == _HistoryStatusFilter.processing,
                  onTap: () => setState(
                    () => _statusFilter = _HistoryStatusFilter.processing,
                  ),
                ),
                _StatusToggle(
                  label: 'Received',
                  selected: _statusFilter == _HistoryStatusFilter.received,
                  onTap: () => setState(
                    () => _statusFilter = _HistoryStatusFilter.received,
                  ),
                ),
                _StatusToggle(
                  label: 'Pending',
                  selected: _statusFilter == _HistoryStatusFilter.pending,
                  onTap: () => setState(
                    () => _statusFilter = _HistoryStatusFilter.pending,
                  ),
                ),
                _StatusToggle(
                  label: 'Failed',
                  selected: _statusFilter == _HistoryStatusFilter.failed,
                  onTap: () => setState(
                    () => _statusFilter = _HistoryStatusFilter.failed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (historyRequests.isEmpty)
              const AppSurface(
                color: AppTheme.surfaceRaised,
                child: Text(
                  'No remote batches match the current filters. Clear filters or refresh the backend history.',
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
                                : request.status == RequestStatus.processing
                                ? 'processing'
                                : request.status == RequestStatus.received
                                ? 'received'
                                : request.status == RequestStatus.failed
                                ? 'failed'
                                : 'pending',
                            color: request.status == RequestStatus.completed
                                ? AppTheme.statusGreen
                                : request.status == RequestStatus.failed
                                ? AppTheme.red
                                : request.status == RequestStatus.processing
                                ? AppTheme.goldDeep
                                : AppTheme.slate,
                            background: request.status == RequestStatus.completed
                                ? AppTheme.sand
                                : request.status == RequestStatus.failed
                                ? AppTheme.dangerSoft
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
                                  widget.onNavigate(AppPage.results);
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
                          final List<String> previewTransforms = request.transforms
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
                                  widget.onNavigate(AppPage.results);
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

enum _HistoryStatusFilter { all, completed, processing, received, pending, failed }

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppTheme.navy : null,
        foregroundColor: selected ? AppTheme.white : AppTheme.navy,
      ),
      child: Text(label),
    );
  }
}
