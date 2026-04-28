import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const List<String> _supportedOutputFormats = <String>[
    'JPG',
    'PNG',
    'WEBP',
    'BMP',
    'GIF',
    'TIFF',
    'ICO',
  ];

  bool _emailNotifications = true;
  bool _processingCompleted = true;
  bool _processingFailed = true;
  bool _nodeChanges = false;
  bool _weeklyReports = false;
  bool _preserveMetadata = true;
  bool _autoOptimize = true;
  bool _autoDownload = false;

  // Profile editing
  late TextEditingController _usernameCtrl;
  late TextEditingController _newPasswordCtrl;
  late TextEditingController _confirmPasswordCtrl;
  bool _savingProfile = false;
  bool _savingPassword = false;
  String? _profileError;
  String? _passwordError;
  String? _profileSuccess;
  String? _passwordSuccess;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _newPasswordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workspace = WorkspaceScope.of(context);
    if (_usernameCtrl.text.isEmpty) {
      _usernameCtrl.text = workspace.session?.username ?? '';
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final workspace = WorkspaceScope.of(context);
    final name = _usernameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _profileError = 'Username cannot be empty.');
      return;
    }
    setState(() {
      _savingProfile = true;
      _profileError = null;
      _profileSuccess = null;
    });
    try {
      await workspace.updateProfile(username: name);
      if (mounted) {
        setState(() {
          _profileSuccess = 'Profile updated successfully.';
          _savingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileError = e.toString();
          _savingProfile = false;
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    final workspace = WorkspaceScope.of(context);
    final newPwd = _newPasswordCtrl.text;
    final confirmPwd = _confirmPasswordCtrl.text;
    if (newPwd.isEmpty) {
      setState(() => _passwordError = 'New password cannot be empty.');
      return;
    }
    if (newPwd != confirmPwd) {
      setState(() => _passwordError = 'Passwords do not match.');
      return;
    }
    setState(() {
      _savingPassword = true;
      _passwordError = null;
      _passwordSuccess = null;
    });
    try {
      await workspace.resetPassword(newPassword: newPwd);
      if (mounted) {
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
        setState(() {
          _passwordSuccess = 'Password updated successfully.';
          _savingPassword = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordError = e.toString();
          _savingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PageIntro(
          kicker: 'Workspace preferences',
          title: 'Settings',
          description:
              'Manage account details, processing defaults and operator preferences with clearer grouping and lower visual noise.',
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
                  iconBackground: AppTheme.sand,
                  title: 'Profile Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SettingsLabeledFieldController(
                        label: 'Username',
                        controller: _usernameCtrl,
                      ),
                      const SizedBox(height: 12),
                      _SettingsLabeledField(
                        label: 'Email Address',
                        initialValue: workspace.session?.identity ?? '',
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (_profileError != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          _profileError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (_profileSuccess != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          _profileSuccess!,
                          style: TextStyle(
                            color: AppTheme.statusGreen,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _savingProfile ? null : _saveProfile,
                          child: _savingProfile
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Changes'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SettingsLabeledFieldController(
                        label: 'New Password',
                        controller: _newPasswordCtrl,
                        obscureText: true,
                        hintText: '••••••••',
                      ),
                      const SizedBox(height: 16),
                      _SettingsLabeledFieldController(
                        label: 'Confirm Password',
                        controller: _confirmPasswordCtrl,
                        obscureText: true,
                        hintText: '••••••••',
                      ),
                      if (_passwordError != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          _passwordError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (_passwordSuccess != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          _passwordSuccess!,
                          style: TextStyle(
                            color: AppTheme.statusGreen,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _savingPassword ? null : _updatePassword,
                          child: _savingPassword
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Update Password'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  icon: Icons.image_outlined,
                  iconColor: AppTheme.orange,
                  iconBackground: AppTheme.infoSoft,
                  title: 'Default Processing Settings',
                  child: Column(
                    children: <Widget>[
                      _SettingsFieldPair(
                        left: _SettingsLabeledDropdown(
                          label: 'Default Output Format',
                          initialValue: 'JPG',
                          items: _supportedOutputFormats,
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
                  iconColor: AppTheme.red,
                  iconBackground: AppTheme.gold,
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

                              final Widget apiField = Expanded(
                                child: _SettingsLabeledField(
                                  label: 'Backend Base URL',
                                  initialValue: workspace.apiBaseUrl,
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
                                    _SettingsLabeledField(
                                      label: 'Backend Base URL',
                                      initialValue: workspace.apiBaseUrl,
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
                          child: const Text('Connected via workspace config'),
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
                              'Connected endpoint',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'REST v1',
                              style: AppTheme.displayStyle(context, size: 30),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Backend proxy target',
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        AppTheme.surfaceContainer,
                        AppTheme.surfaceMuted,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radii.lg),
                    border: Border.all(color: AppTheme.outlineVariant),
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
      radius: AppTheme.radii.lg,
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
                  borderRadius: BorderRadius.circular(AppTheme.radii.sm),
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
    this.keyboardType,
    this.readOnly = false,
  });

  final String label;
  final String? initialValue;
  final TextInputType? keyboardType;
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
          keyboardType: keyboardType,
          decoration: _settingsInputDecoration(null),
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
  return InputDecoration(hintText: hintText);
}

/// Same as [_SettingsLabeledField] but accepts a [TextEditingController]
/// so the parent state can read / write the value.
class _SettingsLabeledFieldController extends StatelessWidget {
  const _SettingsLabeledFieldController({
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: _settingsInputDecoration(hintText),
        ),
      ],
    );
  }
}
