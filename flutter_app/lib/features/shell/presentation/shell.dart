import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/core/workspace/workspace_controller.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/features/admin/presentation/admin_page.dart';
import 'package:imageflow_flutter/features/auth/domain/auth_view.dart';
import 'package:imageflow_flutter/features/auth/presentation/auth_pages.dart';
import 'package:imageflow_flutter/features/dashboard/presentation/dashboard_page.dart';
import 'package:imageflow_flutter/features/history/presentation/history_page.dart';
import 'package:imageflow_flutter/features/logs/presentation/logs_page.dart';
import 'package:imageflow_flutter/features/nodes/presentation/nodes_page.dart';
import 'package:imageflow_flutter/features/progress/presentation/progress_page.dart';
import 'package:imageflow_flutter/features/request_detail/presentation/request_detail_page.dart';
import 'package:imageflow_flutter/features/results/presentation/results_page.dart';
import 'package:imageflow_flutter/features/settings/presentation/settings_page.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/features/upload/presentation/upload_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class ImageFlowApp extends StatefulWidget {
  const ImageFlowApp({super.key});

  @override
  State<ImageFlowApp> createState() => _ImageFlowAppState();
}

class _ImageFlowAppState extends State<ImageFlowApp> {
  static const bool _previewDashboardWithoutAuth = false;
  late final WorkspaceController _workspaceController = WorkspaceController();
  AuthView _authView = AuthView.login;
  AppPage _activePage = AppPage.dashboard;

  Future<void> _handleLogin(String email, String password) async {
    await _workspaceController.login(email: email, password: password);
    setState(() {
      _activePage = _workspaceController.isAdmin
          ? AppPage.admin
          : AppPage.dashboard;
    });
  }

  void _handleLogout() {
    _workspaceController.logout();
    setState(() {
      _authView = AuthView.login;
      _activePage = AppPage.dashboard;
    });
  }

  Future<void> _handleRegister({
    required String username,
    required String email,
    required String password,
    required int roleId,
  }) async {
    await _workspaceController.register(
      username: username,
      email: email,
      password: password,
      roleId: roleId,
    );
    setState(() {
      _authView = AuthView.login;
    });
  }

  Future<void> _handleForgotPassword(String email, String newPassword) async {
    await _workspaceController.forgetPassword(
      email: email,
      newPassword: newPassword,
    );
  }

  void _navigate(AppPage page) {
    setState(() {
      _activePage = page;
    });
  }

  @override
  void dispose() {
    _workspaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceScope(
      controller: _workspaceController,
      child: AnimatedBuilder(
        animation: _workspaceController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Enfok',
            theme: AppTheme.lightTheme(),
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: <PointerDeviceKind>{
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
                PointerDeviceKind.invertedStylus,
                PointerDeviceKind.unknown,
              },
            ),
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child:
                  (_workspaceController.isAuthenticated ||
                      _previewDashboardWithoutAuth)
                  ? _AppShell(
                      key: const ValueKey<String>('shell'),
                      activePage: _activePage,
                      onNavigate: _navigate,
                      onLogout: _handleLogout,
                    )
                  : _buildAuthView(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthView() {
    switch (_authView) {
      case AuthView.login:
        return LoginPage(
          key: const ValueKey<String>('login'),
          onLogin: _handleLogin,
          onRegister: () => setState(() => _authView = AuthView.register),
          onForgotPassword: () => setState(() => _authView = AuthView.forgot),
        );
      case AuthView.register:
        return RegisterPage(
          key: const ValueKey<String>('register'),
          onRegister: _handleRegister,
          onLogin: () => setState(() => _authView = AuthView.login),
        );
      case AuthView.forgot:
        return ForgotPasswordPage(
          key: const ValueKey<String>('forgot'),
          onBack: () => setState(() => _authView = AuthView.login),
          onResetPassword: _handleForgotPassword,
        );
    }
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({
    super.key,
    required this.activePage,
    required this.onNavigate,
    required this.onLogout,
  });

  final AppPage activePage;
  final ValueChanged<AppPage> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 1080;
        final bool mobile = constraints.maxWidth < 760;
        final double sidebarWidth = constraints.maxWidth >= 1440 ? 286 : 264;
        final double contentPadding = mobile ? 12 : (compact ? 16 : 20);
        final double drawerWidth = math.min(
          mobile ? 320 : 360,
          constraints.maxWidth - 20,
        );

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.background,
          drawer: compact
              ? Drawer(
                  width: drawerWidth,
                  backgroundColor: AppTheme.background,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _ShellSidebar(
                        activePage: activePage,
                        onNavigate: (AppPage page) {
                          Navigator.of(context).maybePop();
                          onNavigate(page);
                        },
                        onLogout: onLogout,
                        compact: true,
                      ),
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!compact)
                  SizedBox(
                    width: sidebarWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                      child: _ShellSidebar(
                        activePage: activePage,
                        onNavigate: onNavigate,
                        onLogout: onLogout,
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 0 : 16,
                      16,
                      16,
                      16,
                    ),
                    child: Column(
                      children: <Widget>[
                        _ShellHeader(
                          compact: compact,
                          activePage: activePage,
                          onMenuTap: () =>
                              scaffoldKey.currentState?.openDrawer(),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: AppSurface(
                            padding: EdgeInsets.zero,
                            radius: 32,
                            color: AppTheme.surface,
                            child: SingleChildScrollView(
                              key: ValueKey<AppPage>(activePage),
                              padding: EdgeInsets.all(contentPadding),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1240,
                                  ),
                                  child: _PageViewport(
                                    activePage: activePage,
                                    onNavigate: onNavigate,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageViewport extends StatelessWidget {
  const _PageViewport({required this.activePage, required this.onNavigate});

  final AppPage activePage;
  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    switch (activePage) {
      case AppPage.admin:
        return workspace.isAdmin
            ? AdminPage(onNavigate: onNavigate)
            : const _RestrictedPage(
                title: 'Admin View Required',
                description:
                    'This area is only available for accounts where the backend returns role 1.',
              );
      case AppPage.dashboard:
        return workspace.isAdmin
            ? const _RestrictedPage(
                title: 'Admin Lane Only',
                description:
                    'Admin accounts stay on observability surfaces. Use Admin Center, Logs, and Node metrics instead of the operator workflow.',
              )
            : const DashboardPage();
      case AppPage.upload:
        return workspace.isAdmin
            ? const _RestrictedPage(
                title: 'Admin Lane Only',
                description:
                    'Uploading and processing batches belong to operator accounts. Admin stays focused on logs, metrics, and overall system health.',
              )
            : UploadPage(onNavigate: onNavigate);
      case AppPage.taskBuilder:
        return workspace.isAdmin
            ? const _RestrictedPage(
                title: 'Admin Lane Only',
                description:
                    'Task creation is part of the operator flow. Admin accounts only observe platform health and operational signals.',
              )
            : UploadPage(onNavigate: onNavigate);
      case AppPage.progress:
        return workspace.isAdmin
            ? const _RestrictedPage(
                title: 'Admin Lane Only',
                description:
                    'Progress tracking for user batches is not exposed in the admin lane. Review logs and node pressure instead.',
              )
            : ProgressPage(onNavigate: onNavigate);
      case AppPage.results:
        return workspace.isAdmin
            ? const _RestrictedPage(
                title: 'Admin Lane Only',
                description:
                    'Processed outputs remain in the operator flow. Admin accounts should not browse user results or media.',
              )
            : const ResultsPage();
      case AppPage.history:
        return workspace.isAdmin
            ? const _RestrictedPage(
                title: 'Admin Lane Only',
                description:
                    'Request history stays with the operator workflow. Admin accounts monitor the system without browsing user-owned work.',
              )
            : HistoryPage(onNavigate: onNavigate);
      case AppPage.requestDetail:
        return workspace.isAdmin
            ? const _RestrictedPage(
                title: 'Admin Lane Only',
                description:
                    'Detailed request content is hidden from the admin lane. Use logs and metrics to inspect the platform instead.',
              )
            : const RequestDetailPage();
      case AppPage.nodes:
        return workspace.isAdmin
            ? const NodesPage()
            : const _RestrictedPage(
                title: 'Admin View Required',
                description:
                    'Node metrics and workspace capacity are only visible when the backend returns role 1.',
              );
      case AppPage.logs:
        return workspace.isAdmin
            ? const LogsPage()
            : const _RestrictedPage(
                title: 'Admin View Required',
                description:
                    'Operational logs are reserved for admin accounts and appear when the signed-in user has role 1.',
              );
      case AppPage.settings:
        return const SettingsPage();
    }
  }
}

class _ShellSidebar extends StatelessWidget {
  const _ShellSidebar({
    required this.activePage,
    required this.onNavigate,
    required this.onLogout,
    this.compact = false,
  });

  final AppPage activePage;
  final ValueChanged<AppPage> onNavigate;
  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final bool isAdmin = workspace.isAdmin;
    final List<AppPage> utilityPages = isAdmin ? _adminUtilityPages : _userUtilityPages;
    final List<AppPage> primaryPages = isAdmin ? _adminPrimaryPages : _userPrimaryPages;
    final bool utilityActive = <AppPage>[
      AppPage.settings,
      if (isAdmin) ...<AppPage>[AppPage.nodes, AppPage.logs],
    ].contains(activePage);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SidebarBrandCard(compact: compact, isAdmin: isAdmin),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onNavigate(
                isAdmin ? AppPage.logs : AppPage.upload,
              ),
              icon: Icon(
                isAdmin
                    ? Icons.monitor_heart_outlined
                    : Icons.add_photo_alternate_outlined,
                size: 18,
              ),
              label: Text(isAdmin ? 'Open logs' : 'New batch'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.navy,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              key: PageStorageKey<String>(
                compact ? 'shell-sidebar-mobile-scroll' : 'shell-sidebar-scroll',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: primaryPages.map((AppPage page) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _SidebarTile(
                      label: page.label,
                      icon: page.icon,
                      active: page == activePage,
                      onTap: () => onNavigate(page),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          _UtilityLauncher(
            active: utilityActive,
            label: isAdmin ? 'Admin tools' : 'Workspace tools',
            onTap: () => _showUtilitySheet(
              context,
              onNavigate,
              utilityPages: utilityPages,
              isAdmin: isAdmin,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.navy,
                backgroundColor: AppTheme.white,
                minimumSize: const Size(0, 50),
                side: BorderSide(
                  color: AppTheme.surfaceContainer.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showUtilitySheet(
  BuildContext context,
  ValueChanged<AppPage> onNavigate, {
  required List<AppPage> utilityPages,
  required bool isAdmin,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext modalContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.outlineVariant),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isAdmin ? 'Admin tools' : 'Workspace tools',
                  style: Theme.of(modalContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  isAdmin
                      ? 'Logs and performance views live here so the batch flow stays clean for operators.'
                      : 'Secondary areas live here so the main navigation stays focused on the batch flow.',
                  style: Theme.of(modalContext).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                  ),
                ),
                const SizedBox(height: 18),
                for (final AppPage page in utilityPages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _UtilitySheetTile(
                      page: page,
                      onTap: () {
                        Navigator.of(modalContext).pop();
                        onNavigate(page);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SidebarBrandCard extends StatelessWidget {
  const _SidebarBrandCard({required this.compact, required this.isAdmin});

  final bool compact;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const LuminousLogo(tone: LuminousBrandTone.onLight, height: 50),
          const SizedBox(height: 10),
          if (isAdmin) ...<Widget>[
            const StatusChip(
              label: 'Admin role',
              color: AppTheme.goldDeep,
              background: AppTheme.sand,
              icon: Icons.admin_panel_settings_outlined,
            ),
            const SizedBox(height: 10),
          ],
          Text(
            isAdmin
                ? 'Monitor logs, capacity and workspace performance from the admin lane.'
                : 'Process image batches with a guided flow.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.navy.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.compact,
    required this.activePage,
    required this.onMenuTap,
  });

  final bool compact;
  final AppPage activePage;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceScope.of(context);
    final DateTime now = DateTime.now();
    final String today = '${_monthName(now.month)} ${now.day}, ${now.year}';

    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      radius: 28,
      color: AppTheme.white,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 860;

          final Widget heading = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                activePage.label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.slate,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _pageHeadline(activePage),
                style: AppTheme.displayStyle(
                  context,
                  size: compact ? 28 : 32,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _pageSummary(activePage),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
              ),
            ],
          );

          final Widget meta = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _HeaderPill(icon: Icons.calendar_today_outlined, label: today),
              _HeaderPill(
                icon: workspace.isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.person_outline_rounded,
                label: workspace.isAdmin ? 'Admin role' : 'Operator role',
              ),
              const _HeaderPill(
                icon: Icons.monitor_heart_outlined,
                label: 'Workspace ready',
              ),
            ],
          );

          return stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        if (compact) ...<Widget>[
                          IconButton(
                            onPressed: onMenuTap,
                            icon: const Icon(Icons.menu_rounded),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(child: heading),
                      ],
                    ),
                    const SizedBox(height: 14),
                    meta,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (compact) ...<Widget>[
                      IconButton(
                        onPressed: onMenuTap,
                        icon: const Icon(Icons.menu_rounded),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(child: heading),
                    const SizedBox(width: 16),
                    meta,
                  ],
                );
        },
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppTheme.navy),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.surfaceContainer
                : AppTheme.surfaceContainer.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active
                  ? AppTheme.secondary
                  : AppTheme.surfaceContainer.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: active ? AppTheme.onSurface : AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: active ? AppTheme.surfaceContainer : AppTheme.navy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: active ? AppTheme.navy : AppTheme.sand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UtilityLauncher extends StatelessWidget {
  const _UtilityLauncher({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.tune_rounded, size: 18),
        label: Text(active ? '$label open' : label),
        style: OutlinedButton.styleFrom(
          foregroundColor: active ? AppTheme.white : AppTheme.surfaceContainer,
          backgroundColor: active
              ? AppTheme.surfaceContainer.withValues(alpha: 0.12)
              : AppTheme.surfaceContainer.withValues(alpha: 0.03),
          side: BorderSide(
            color: active
                ? AppTheme.secondary
                : AppTheme.surfaceContainer.withValues(alpha: 0.16),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),
    );
  }
}

class _UtilitySheetTile extends StatelessWidget {
  const _UtilitySheetTile({required this.page, required this.onTap});

  final AppPage page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(page.icon, size: 18, color: AppTheme.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                page.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }
}

class _RestrictedPage extends StatelessWidget {
  const _RestrictedPage({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const StatusChip(
            label: 'Restricted',
            color: AppTheme.red,
            background: AppTheme.dangerSoft,
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTheme.displayStyle(context, size: 28)),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate, height: 1.6),
          ),
        ],
      ),
    );
  }
}

const List<AppPage> _adminPrimaryPages = <AppPage>[
  AppPage.admin,
];

const List<AppPage> _userPrimaryPages = <AppPage>[
  AppPage.dashboard,
  AppPage.upload,
  AppPage.progress,
  AppPage.results,
  AppPage.history,
];

const List<AppPage> _adminUtilityPages = <AppPage>[
  AppPage.nodes,
  AppPage.logs,
  AppPage.settings,
];

const List<AppPage> _userUtilityPages = <AppPage>[AppPage.settings];

String _monthName(int month) {
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String _pageHeadline(AppPage page) {
    switch (page) {
      case AppPage.admin:
        return 'Admin command center';
      case AppPage.dashboard:
        return 'Workspace at a glance';
    case AppPage.upload:
      return 'Bring new work in';
    case AppPage.taskBuilder:
      return 'Bring new work in';
    case AppPage.progress:
      return 'Follow active work';
    case AppPage.results:
      return 'Review finished outputs';
    case AppPage.history:
      return 'Look back on past work';
    case AppPage.requestDetail:
      return 'Inspect request details';
    case AppPage.nodes:
      return 'Watch workspace capacity';
    case AppPage.logs:
      return 'Read workspace activity';
    case AppPage.settings:
      return 'Adjust workspace behavior';
  }
}

String _pageSummary(AppPage page) {
  switch (page) {
      case AppPage.admin:
      return 'Review logs, worker pressure and operational signals reserved for admin accounts.';
    case AppPage.dashboard:
      return 'A simpler read on activity, queue pressure and the work that needs attention.';
    case AppPage.upload:
      return 'Stage new assets and validate them before they move into review.';
    case AppPage.taskBuilder:
      return 'Stage new assets and configure them inside the upload modal.';
    case AppPage.progress:
      return 'Track active work, timing and blockers in one clear view.';
    case AppPage.results:
      return 'Review outcomes and exports without losing context.';
    case AppPage.history:
      return 'Look back at prior requests and compare how work moved over time.';
    case AppPage.requestDetail:
      return 'Zoom into one request and inspect the details that matter.';
    case AppPage.nodes:
      return 'See where capacity is carrying more weight and where more room is available.';
    case AppPage.logs:
      return 'Surface important events with enough clarity to spot patterns quickly.';
    case AppPage.settings:
      return 'Adjust workspace rules, defaults, and operator-facing behavior.';
  }
}
