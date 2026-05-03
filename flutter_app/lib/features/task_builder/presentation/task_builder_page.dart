import 'package:flutter/material.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/shared/widgets/batch_pipeline_editor.dart';

class TaskBuilderPage extends StatelessWidget {
  const TaskBuilderPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BatchPipelineEditor(
        title: 'Task Builder',
        subtitle:
            'Configure the full worker pipeline from the UI, including every supported transformation and parameter exposed by the node.',
        showApplyButton: false,
        startButtonLabel: 'Start Processing',
        onStarted: () => onNavigate(AppPage.progress),
      ),
    );
  }
}
