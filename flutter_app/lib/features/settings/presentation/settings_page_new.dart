import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Profile controllers
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  // Password controllers
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  // Preferences state
  bool _emailNotifications = true;
  bool _processingCompleted = true;
  bool _processingFailed = true;
  bool _nodeChanges = false;
  bool _weeklyReports = false;
  bool _preserveMetadata = true;
  bool _autoOptimize = true;
  bool _autoDownload = false;

  bool _isSavingProfile = false;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadProfileData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final workspace = WorkspaceScope.of(context);
    if (workspace.session != null) {
      _usernameController.text = workspace.session!.username ?? 'User';
      _emailController.text = workspace.session!.identity;
    }
  }

  Future<void> _saveProfile() async {
    final workspace = WorkspaceScope.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!mounted) return;
    setState(() => _isSavingProfile = true);

    try {
      await workspace.updateProfile(username: _usernameController.text);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _updatePassword() async {
    final workspace = WorkspaceScope.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_newPasswordController.text != _confirmPasswordController.text) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('New password cannot be empty')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isUpdatingPassword = true);

    try {
      await workspace.resetPassword(newPassword: _newPasswordController.text);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
      }
    }
  }

  Future<void> _copyUrl() async {
    final workspace = WorkspaceScope.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await Clipboard.setData(ClipboardData(text: workspace.apiBaseUrl));
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
    );
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
                    children: <Widget>[
                      _SettingsFieldPair(
                        left: _SettingsLabeledField(
                          label: 'Username',
                          controller: _usernameController,
                        ),
                        right: _SettingsLabeledField(
                          label: 'Email Address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _isSavingProfile ? null : _saveProfile,
                          child: _isSavingProfile
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
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
                    children: <Widget>[
                      _SettingsLabeledField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        hintText: '••••••••',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _SettingsFieldPair(
                        left: _SettingsLabeledField(
                          label: 'New Password',
                          controller: _newPasswordController,
                          hintText: '••••••••',
                          obscureText: true,
                        ),
                        right: _SettingsLabeledField(
                          label: 'Confirm Password',
                          controller: _confirmPasswordController,
                          hintText: '••••••••',
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _isUpdatingPassword
                              ? null
                              : _updatePassword,
                          child: _isUpdatingPassword
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
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
                          onChanged: (_) {},
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Preferences saved'),
                              ),
                            );
                          },
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
                                onPressed: _copyUrl,
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
    this.controller,
    this.initialValue,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController? controller;
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
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: _settingsInputDecoration(hintText),
        ),
      ],
    );
  }
}

class _SettingsLabeledDropdown extends StatefulWidget {
  const _SettingsLabeledDropdown({
    required this.label,
    required this.initialValue,
    required this.items,
    this.onChanged,
  });

  final String label;
  final String initialValue;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  @override
  State<_SettingsLabeledDropdown> createState() =>
      _SettingsLabeledDropdownState();
}

class _SettingsLabeledDropdownState extends State<_SettingsLabeledDropdown> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedValue,
          isExpanded: true,
          decoration: _settingsInputDecoration(null),
          items: widget.items
              .map(
                (String item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: (String? value) {
            if (value != null) {
              setState(() => _selectedValue = value);
              widget.onChanged?.call(value);
            }
          },
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                    ),
                  ),
                  const SizedBox(width: 8),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: const OutlineInputBorder(),
  );
}
