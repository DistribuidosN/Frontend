import 'package:flutter/material.dart';
import 'package:imageflow_flutter/features/dashboard/domain/dashboard_models.dart';

const Map<DashboardWindow, DashboardView>
dashboardViews = <DashboardWindow, DashboardView>{
  DashboardWindow.day: DashboardView(
    summary:
        'Editorial work is moving cleanly. Review stays light, delivery timing stays under target, and only two assets need attention.',
    focus:
        'The morning burst settled early, so the rest of the day stayed easy to read.',
    cards: <OverviewMetric>[
      OverviewMetric(
        label: 'Images processed',
        value: '4,218',
        note: '+9.2% vs yesterday',
        icon: Icons.image_outlined,
      ),
      OverviewMetric(
        label: 'Median turnaround',
        value: '3.4s',
        note: 'under the 4s SLA',
        icon: Icons.schedule_outlined,
      ),
      OverviewMetric(
        label: 'Manual review',
        value: '02',
        note: 'profile mismatches',
        icon: Icons.verified_user_outlined,
      ),
    ],
    support: <SupportMetric>[
      SupportMetric(
        label: 'Live throughput',
        value: '82 img/min',
        note: 'strong pace through the morning window',
      ),
      SupportMetric(
        label: 'Node utilization',
        value: '72%',
        note: 'comfortable room before pressure builds',
      ),
      SupportMetric(
        label: 'Recovery buffer',
        value: '14 min',
        note: 'enough room for a smooth handoff',
      ),
    ],
    chart: <ThroughputPoint>[
      ThroughputPoint(label: '08', processed: 226, queued: 24),
      ThroughputPoint(label: '10', processed: 338, queued: 34),
      ThroughputPoint(label: '12', processed: 412, queued: 48),
      ThroughputPoint(label: '14', processed: 486, queued: 52),
      ThroughputPoint(label: '16', processed: 541, queued: 44),
      ThroughputPoint(label: '18', processed: 397, queued: 28),
      ThroughputPoint(label: '20', processed: 301, queued: 18),
    ],
  ),
  DashboardWindow.week: DashboardView(
    summary:
        'The week stayed calmer than the volume suggests. Review load is down, handoff stayed smooth, and Thursday was the only real pressure point.',
    focus:
        'The busiest stretch was absorbed early before it turned into visible backlog.',
    cards: <OverviewMetric>[
      OverviewMetric(
        label: 'Images processed',
        value: '24,583',
        note: '+12.5% vs last week',
        icon: Icons.image_outlined,
      ),
      OverviewMetric(
        label: 'Median turnaround',
        value: '3.8s',
        note: 'consistent across presets',
        icon: Icons.schedule_outlined,
      ),
      OverviewMetric(
        label: 'Manual review',
        value: '07',
        note: 'down from 11 last week',
        icon: Icons.verified_user_outlined,
      ),
    ],
    support: <SupportMetric>[
      SupportMetric(
        label: 'Live throughput',
        value: '64 img/min',
        note: 'Thursday carried the heaviest pace',
      ),
      SupportMetric(
        label: 'Node utilization',
        value: '68%',
        note: 'work stayed balanced across the week',
      ),
      SupportMetric(
        label: 'Recovery buffer',
        value: '12 min',
        note: 'still enough room for a calm recovery',
      ),
    ],
    chart: <ThroughputPoint>[
      ThroughputPoint(label: 'Mon', processed: 1240, queued: 104),
      ThroughputPoint(label: 'Tue', processed: 1890, queued: 162),
      ThroughputPoint(label: 'Wed', processed: 2100, queued: 194),
      ThroughputPoint(label: 'Thu', processed: 1750, queued: 228),
      ThroughputPoint(label: 'Fri', processed: 2400, queued: 176),
      ThroughputPoint(label: 'Sat', processed: 1680, queued: 118),
      ThroughputPoint(label: 'Sun', processed: 1320, queued: 92),
    ],
  ),
  DashboardWindow.month: DashboardView(
    summary:
        'Volume is up, exceptions are rarer, and the current setup can absorb another commercial lane before expansion becomes urgent.',
    focus: 'Only month-end delivery windows meaningfully tighten the flow.',
    cards: <OverviewMetric>[
      OverviewMetric(
        label: 'Images processed',
        value: '103,420',
        note: '+18.1% vs prior month',
        icon: Icons.image_outlined,
      ),
      OverviewMetric(
        label: 'Median turnaround',
        value: '4.1s',
        note: 'stable despite higher volume',
        icon: Icons.schedule_outlined,
      ),
      OverviewMetric(
        label: 'Manual review',
        value: '19',
        note: 'mostly malformed TIFFs',
        icon: Icons.verified_user_outlined,
      ),
    ],
    support: <SupportMetric>[
      SupportMetric(
        label: 'Live throughput',
        value: '58 img/min',
        note: 'commercial presets lead the month',
      ),
      SupportMetric(
        label: 'Node utilization',
        value: '74%',
        note: 'room remains for one extra lane',
      ),
      SupportMetric(
        label: 'Recovery buffer',
        value: '09 min',
        note: 'watch month-end delivery windows',
      ),
    ],
    chart: <ThroughputPoint>[
      ThroughputPoint(label: 'W1', processed: 22140, queued: 1280),
      ThroughputPoint(label: 'W2', processed: 24880, queued: 1430),
      ThroughputPoint(label: 'W3', processed: 27640, queued: 1675),
      ThroughputPoint(label: 'W4', processed: 28760, queued: 1522),
    ],
  ),
};

const List<NodeHealth> clusterNodes = <NodeHealth>[
  NodeHealth(
    id: 'lane-01',
    zone: 'Editorial',
    load: 84,
    throughput: '312 img/h',
    tone: NodeTone.balancing,
  ),
  NodeHealth(
    id: 'lane-02',
    zone: 'Catalog',
    load: 68,
    throughput: '284 img/h',
    tone: NodeTone.stable,
  ),
  NodeHealth(
    id: 'lane-03',
    zone: 'Campaigns',
    load: 57,
    throughput: '246 img/h',
    tone: NodeTone.stable,
  ),
  NodeHealth(
    id: 'lane-04',
    zone: 'Exports',
    load: 79,
    throughput: '298 img/h',
    tone: NodeTone.balancing,
  ),
];

const List<BatchActivity> recentBatches = <BatchActivity>[
  BatchActivity(
    id: 'REQ-4522',
    preset: 'Editorial Cleanup',
    owner: 'Brand Studio',
    images: 245,
    status: BatchStatus.running,
    eta: '2m 14s remaining',
    completion: 68,
  ),
  BatchActivity(
    id: 'REQ-4521',
    preset: 'Marketplace Export',
    owner: 'Commerce Ops',
    images: 128,
    status: BatchStatus.completed,
    eta: 'Delivered 8m ago',
    completion: 100,
  ),
  BatchActivity(
    id: 'REQ-4520',
    preset: 'Retouch + Tone Match',
    owner: 'Campaign Team',
    images: 89,
    status: BatchStatus.review,
    eta: 'Waiting on 2 assets',
    completion: 91,
  ),
  BatchActivity(
    id: 'REQ-4519',
    preset: 'Archive Normalization',
    owner: 'Ops Library',
    images: 456,
    status: BatchStatus.running,
    eta: '6m 03s remaining',
    completion: 41,
  ),
];
