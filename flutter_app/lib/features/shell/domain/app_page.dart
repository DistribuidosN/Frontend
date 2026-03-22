import 'package:flutter/material.dart';

enum AppPage {
  dashboard,
  upload,
  taskBuilder,
  progress,
  results,
  history,
  requestDetail,
  nodes,
  logs,
  settings,
}

extension AppPageMeta on AppPage {
  String get label {
    switch (this) {
      case AppPage.dashboard:
        return 'Dashboard';
      case AppPage.upload:
        return 'Upload';
      case AppPage.taskBuilder:
        return 'Task Builder';
      case AppPage.progress:
        return 'Progress';
      case AppPage.results:
        return 'Results';
      case AppPage.history:
        return 'History';
      case AppPage.requestDetail:
        return 'Request Detail';
      case AppPage.nodes:
        return 'Worker Nodes';
      case AppPage.logs:
        return 'Logs';
      case AppPage.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AppPage.dashboard:
        return Icons.dashboard_outlined;
      case AppPage.upload:
        return Icons.file_upload_outlined;
      case AppPage.taskBuilder:
        return Icons.tune_outlined;
      case AppPage.progress:
        return Icons.monitor_heart_outlined;
      case AppPage.results:
        return Icons.check_circle_outline;
      case AppPage.history:
        return Icons.schedule_outlined;
      case AppPage.requestDetail:
        return Icons.receipt_long_outlined;
      case AppPage.nodes:
        return Icons.dns_outlined;
      case AppPage.logs:
        return Icons.description_outlined;
      case AppPage.settings:
        return Icons.settings_outlined;
    }
  }
}

const List<AppPage> shellPages = <AppPage>[
  AppPage.dashboard,
  AppPage.upload,
  AppPage.taskBuilder,
  AppPage.progress,
  AppPage.results,
  AppPage.history,
  AppPage.nodes,
  AppPage.logs,
  AppPage.settings,
];
