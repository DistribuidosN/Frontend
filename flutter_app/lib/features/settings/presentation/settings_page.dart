import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emailNotifications = true;
  bool _processingCompleted = true;
  bool _processingFailed = true;
  bool _nodeChanges = false;
  bool _weeklyReports = false;
  bool _preserveMetadata = true;
  bool _autoOptimize = true;
  bool _autoDownload = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Settings', style: AppTheme.displayStyle(context, size: 30)),
        const SizedBox(height: 8),
        Text(
          'Manage your account and application preferences',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 1120;

            final Widget mainColumn = Column(
              children: <Widget>[
                _SettingsSection(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppTheme.ink,
                  iconBackground: Colors.white,
                  title: 'Profile Information',
                  child: Column(
                    children: <Widget>[
                      _SettingsFieldPair(
                        left: const _SettingsLabeledField(
                          label: 'First Name',
                          initialValue: 'Alex',
                        ),
                        right: const _SettingsLabeledField(
                          label: 'Last Name',
                          initialValue: 'Morgan',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _SettingsLabeledField(
                        label: 'Email Address',
                        initialValue: 'alex@imageflow.io',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppTheme.danger,
                  iconBackground: AppTheme.dangerSoft,
                  title: 'Change Password',
                  child: Column(
                    children: <Widget>[
                      const _SettingsLabeledField(
                        label: 'Current Password',
                        hintText: '********',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _SettingsFieldPair(
                        left: const _SettingsLabeledField(
                          label: 'New Password',
                          hintText: '********',
                          obscureText: true,
                        ),
                        right: const _SettingsLabeledField(
                          label: 'Confirm Password',
                          hintText: '********',
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Update Password'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  icon: Icons.image_outlined,
                  iconColor: const Color(0xFF1E3A8A),
                  iconBackground: AppTheme.infoSoft,
                  title: 'Default Processing Settings',
                  child: Column(
                    children: <Widget>[
                      _SettingsFieldPair(
                        left: const _SettingsLabeledDropdown(
                          label: 'Default Output Format',
                          initialValue: 'JPG',
                          items: <String>['JPG', 'PNG', 'WEBP', 'TIFF'],
                        ),
                        right: const _SettingsLabeledDropdown(
                          label: 'Default Quality',
                          initialValue: 'Medium (85%)',
                          items: <String>[
                            'High (90%)',
                            'Medium (85%)',
                            'Low (70%)',
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SettingsCheckboxRow(
                        label: 'Preserve original metadata by default',
                        value: _preserveMetadata,
                        alignment: _CheckboxAlignment.leading,
                        onChanged: (bool value) =>
                            setState(() => _preserveMetadata = value),
                      ),
                      _SettingsCheckboxRow(
                        label: 'Enable auto-optimization',
                        value: _autoOptimize,
                        alignment: _CheckboxAlignment.leading,
                        onChanged: (bool value) =>
                            setState(() => _autoOptimize = value),
                      ),
                      _SettingsCheckboxRow(
                        label:
                            'Automatically download results after processing',
                        value: _autoDownload,
                        alignment: _CheckboxAlignment.leading,
                        onChanged: (bool value) =>
                            setState(() => _autoDownload = value),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Save Preferences'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final Widget sideColumn = Column(
              children: <Widget>[
                _SettingsSection(
                  icon: Icons.notifications_none_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBackground: const Color(0xFFF3E8FF),
                  title: 'Notifications',
                  child: Column(
                    children: <Widget>[
                      _SettingsCheckboxRow(
                        label: 'Email notifications',
                        value: _emailNotifications,
                        alignment: _CheckboxAlignment.trailing,
                        onChanged: (bool value) =>
                            setState(() => _emailNotifications = value),
                      ),
                      _SettingsCheckboxRow(
                        label: 'Processing completed',
                        value: _processingCompleted,
                        alignment: _CheckboxAlignment.trailing,
                        onChanged: (bool value) =>
                            setState(() => _processingCompleted = value),
                      ),
                      _SettingsCheckboxRow(
                        label: 'Processing failed',
                        value: _processingFailed,
                        alignment: _CheckboxAlignment.trailing,
                        onChanged: (bool value) =>
                            setState(() => _processingFailed = value),
                      ),
                      _SettingsCheckboxRow(
                        label: 'Node status changes',
                        value: _nodeChanges,
                        alignment: _CheckboxAlignment.trailing,
                        onChanged: (bool value) =>
                            setState(() => _nodeChanges = value),
                      ),
                      _SettingsCheckboxRow(
                        label: 'Weekly reports',
                        value: _weeklyReports,
                        alignment: _CheckboxAlignment.trailing,
                        onChanged: (bool value) =>
                            setState(() => _weeklyReports = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  icon: Icons.key_outlined,
                  iconColor: AppTheme.warning,
                  iconBackground: AppTheme.warningSoft,
                  title: 'API Access',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LayoutBuilder(
                        builder:
                            (
                              BuildContext context,
                              BoxConstraints fieldConstraints,
                            ) {
                              final bool fieldStacked =
                                  fieldConstraints.maxWidth < 420;

                              final Widget apiField = const Expanded(
                                child: _SettingsLabeledField(
                                  label: 'API Key',
                                  initialValue: 'sk_live_****************',
                                  obscureText: true,
                                  readOnly: true,
                                ),
                              );

                              final Widget copyButton = OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text('Copy'),
                              );

                              if (fieldStacked) {
                                return Column(
                                  children: <Widget>[
                                    const _SettingsLabeledField(
                                      label: 'API Key',
                                      initialValue: 'sk_live_****************',
                                      obscureText: true,
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: copyButton,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  apiField,
                                  const SizedBox(width: 12),
                                  copyButton,
                                ],
                              );
                            },
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Regenerate API Key'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.border),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Usage this month',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1,247',
                              style: AppTheme.displayStyle(context, size: 30),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'API requests',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Colors.white, AppTheme.canvasSoft],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Need Help?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check out our documentation or contact support.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('View Documentation'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  mainColumn,
                  const SizedBox(height: 18),
                  sideColumn,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 2, child: mainColumn),
                const SizedBox(width: 24),
                Expanded(child: sideColumn),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _SettingsFieldPair extends StatelessWidget {
  const _SettingsFieldPair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: <Widget>[left, const SizedBox(height: 16), right],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _SettingsLabeledField extends StatelessWidget {
  const _SettingsLabeledField({
    required this.label,
    this.initialValue,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
  });

  final String label;
  final String? initialValue;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: _settingsInputDecoration(hintText),
        ),
      ],
    );
  }
}

class _SettingsLabeledDropdown extends StatelessWidget {
  const _SettingsLabeledDropdown({
    required this.label,
    required this.initialValue,
    required this.items,
  });

  final String label;
  final String initialValue;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: initialValue,
          isExpanded: true,
          decoration: _settingsInputDecoration(null),
          items: items
              .map(
                (String item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: (_) {},
        ),
      ],
    );
  }
}

enum _CheckboxAlignment { leading, trailing }

class _SettingsCheckboxRow extends StatelessWidget {
  const _SettingsCheckboxRow({
    required this.label,
    required this.value,
    required this.alignment,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final _CheckboxAlignment alignment;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final Widget checkbox = Checkbox(
      value: value,
      onChanged: (bool? next) => onChanged(next ?? false),
    );

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: alignment == _CheckboxAlignment.leading
              ? <Widget>[
                  checkbox,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                    ),
                  ),
                ]
              : <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  checkbox,
                ],
        ),
      ),
    );
  }
}

InputDecoration _settingsInputDecoration(String? hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: AppTheme.canvasSoft,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
