import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/results/data/results_mock_data.dart';
import 'package:imageflow_flutter/features/results/domain/result_asset.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

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
                    'Processing Results',
                    style: AppTheme.displayStyle(context, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request ID: req-4522 - Completed successfully',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download All (ZIP)'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppSurface(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppTheme.successSoft,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'All images processed successfully',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '24 images - Completed in 52 seconds',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AdaptiveGrid(
                minItemWidth: 180,
                childAspectRatio: 1.5,
                children: const <Widget>[
                  SummaryMetricCard(
                    label: 'Total Images',
                    value: '24',
                    color: AppTheme.ink,
                  ),
                  SummaryMetricCard(
                    label: 'Success Rate',
                    value: '100%',
                    color: AppTheme.success,
                  ),
                  SummaryMetricCard(
                    label: 'Processing Time',
                    value: '52s',
                    color: AppTheme.ink,
                  ),
                  SummaryMetricCard(
                    label: 'Output Size',
                    value: '38.4 MB',
                    color: AppTheme.ink,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'Sample Comparison',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AdaptiveGrid(
                minItemWidth: 320,
                childAspectRatio: 1.3,
                children: const <Widget>[
                  ImageComparisonCard(label: 'Before', grayscale: false),
                  ImageComparisonCard(label: 'After', grayscale: true),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.start,
                children: sampleTransforms
                    .map(
                      (String transform) => StatusChip(
                        label: transform,
                        color: AppTheme.ink,
                        background: AppTheme.sand,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionPanel(
          title: 'All Results',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TogglePill(label: 'Grid View', selected: true, onTap: () {}),
              const SizedBox(width: 8),
              TogglePill(label: 'List View', selected: false, onTap: () {}),
            ],
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int crossAxisCount = constraints.maxWidth >= 1200
                  ? 6
                  : constraints.maxWidth >= 900
                  ? 4
                  : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
                children: resultAssets.map((ResultAsset result) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.canvasSoft,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.image_outlined,
                                  size: 30,
                                  color: AppTheme.muted,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SmallIconButton(
                                      icon: Icons.zoom_in_rounded,
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    SmallIconButton(
                                      icon: Icons.download_rounded,
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.size,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
