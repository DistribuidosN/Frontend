import 'package:flutter/widgets.dart';
import 'package:imageflow_flutter/core/workspace/workspace_controller.dart';

class WorkspaceScope extends InheritedNotifier<WorkspaceController> {
  const WorkspaceScope({
    super.key,
    required WorkspaceController controller,
    required super.child,
  }) : super(notifier: controller);

  static WorkspaceController of(BuildContext context) {
    final WorkspaceScope? scope = context
        .dependOnInheritedWidgetOfExactType<WorkspaceScope>();
    assert(scope != null, 'WorkspaceScope not found in widget tree.');
    return scope!.notifier!;
  }
}
