import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';

IconData logLevelIcon(LogLevel level) {
  switch (level) {
    case LogLevel.success:
      return Icons.check_circle_outline;
    case LogLevel.info:
      return Icons.info_outline;
    case LogLevel.warning:
      return Icons.warning_amber_outlined;
    case LogLevel.error:
      return Icons.cancel_outlined;
  }
}

String logLevelLabel(LogLevel level) {
  switch (level) {
    case LogLevel.success:
      return 'success';
    case LogLevel.info:
      return 'info';
    case LogLevel.warning:
      return 'warning';
    case LogLevel.error:
      return 'error';
  }
}

Color logLevelColor(LogLevel level) {
  switch (level) {
    case LogLevel.success:
      return AppTheme.statusGreen;
    case LogLevel.info:
      return AppTheme.info;
    case LogLevel.warning:
      return AppTheme.warning;
    case LogLevel.error:
      return AppTheme.danger;
  }
}

Color logLevelBackground(LogLevel level) {
  switch (level) {
    case LogLevel.success:
      return AppTheme.sand;
    case LogLevel.info:
      return AppTheme.infoSoft;
    case LogLevel.warning:
      return AppTheme.warningSoft;
    case LogLevel.error:
      return AppTheme.dangerSoft;
  }
}
