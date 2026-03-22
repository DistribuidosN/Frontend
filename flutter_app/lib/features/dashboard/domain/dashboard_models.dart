import 'package:flutter/material.dart';

enum DashboardWindow { day, week, month }

enum BatchStatus { running, completed, review }

enum NodeTone { stable, balancing, warm }

extension DashboardWindowMeta on DashboardWindow {
  String get label {
    switch (this) {
      case DashboardWindow.day:
        return 'Today';
      case DashboardWindow.week:
        return 'This Week';
      case DashboardWindow.month:
        return 'This Month';
    }
  }
}

class OverviewMetric {
  const OverviewMetric({
    required this.label,
    required this.value,
    required this.note,
    required this.icon,
  });

  final String label;
  final String value;
  final String note;
  final IconData icon;
}

class SupportMetric {
  const SupportMetric({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;
}

class ThroughputPoint {
  const ThroughputPoint({
    required this.label,
    required this.processed,
    required this.queued,
  });

  final String label;
  final int processed;
  final int queued;
}

class DashboardView {
  const DashboardView({
    required this.summary,
    required this.focus,
    required this.cards,
    required this.support,
    required this.chart,
  });

  final String summary;
  final String focus;
  final List<OverviewMetric> cards;
  final List<SupportMetric> support;
  final List<ThroughputPoint> chart;
}

class NodeHealth {
  const NodeHealth({
    required this.id,
    required this.zone,
    required this.load,
    required this.throughput,
    required this.tone,
  });

  final String id;
  final String zone;
  final int load;
  final String throughput;
  final NodeTone tone;
}

class BatchActivity {
  const BatchActivity({
    required this.id,
    required this.preset,
    required this.owner,
    required this.images,
    required this.status,
    required this.eta,
    required this.completion,
  });

  final String id;
  final String preset;
  final String owner;
  final int images;
  final BatchStatus status;
  final String eta;
  final int completion;
}
