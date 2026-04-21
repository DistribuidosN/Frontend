import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/workspace/workspace_controller.dart';
import 'package:imageflow_flutter/core/workspace/workspace_scope.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
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
import 'package:imageflow_flutter/features/task_builder/presentation/task_builder_page.dart';
import 'package:imageflow_flutter/features/upload/presentation/upload_page.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class ImageFlowApp extends StatefulWidget {
  const ImageFlowApp({super.key});

  @override
  State<ImageFlowApp> createState() => _ImageFlowAppState();
}

class _ImageFlowAppState extends State<ImageFlowApp> {
  late final WorkspaceController _workspaceController = WorkspaceController();
  AuthView _authView = AuthView.login;
  AppPage _activePage = AppPage.dashboard;

  Future<void> _handleLogin(String email, String password) async {
    await _workspaceController.login(email: email, password: password);
    setState(() {
      _activePage = AppPage.dashboard;
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
  }) async {
    await _workspaceController.register(
      username: username,
      email: email,
      password: password,
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
              child: _workspaceController.isAuthenticated
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
        final double viewportWidth = constraints.maxWidth;
        final bool compact = viewportWidth < 1200;
        final bool mobile = viewportWidth < 760;
        final bool desktopLarge = viewportWidth >= 1540;
        final bool desktopMedium = viewportWidth >= 1360;

        final double railWidth = desktopLarge
            ? 392
            : (desktopMedium ? 364 : 344);
        final double railPaddingH = desktopLarge ? 24 : 18;
        final double railPaddingV = desktopLarge ? 24 : 18;
        final double sidebarMaxWidth = desktopLarge ? 344 : 332;
        final double drawerEdgeGap = mobile ? 8 : 14;
        final double drawerWidth = math.min(
          mobile ? 356 : 396,
          viewportWidth - (drawerEdgeGap * 2),
        );
        final double contentHorizontalPadding = compact
            ? (mobile ? 14 : 18)
            : (desktopLarge ? 34 : 28);

        return Scaffold(
          key: scaffoldKey,
          drawer: compact
              ? Drawer(
                  width: drawerWidth,
                  backgroundColor: AppTheme.navy.withValues(alpha: 0.92),
                  elevation: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        mobile ? 10 : 14,
                        mobile ? 12 : 16,
                        mobile ? 10 : 14,
                        mobile ? 10 : 14,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 344),
                          child: _ShellSidebar(
                            dropdownMode: true,
                            activePage: activePage,
                            onNavigate: (AppPage page) {
                              Navigator.of(context).maybePop();
                              onNavigate(page);
                            },
                            onLogout: onLogout,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppTheme.background,
                        AppTheme.surfaceContainer.withValues(alpha: 0.55),
                        AppTheme.background,
                      ],
                      stops: const <double>[0, 0.48, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -140,
                top: 90,
                child: IgnorePointer(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceMuted.withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (!compact)
                      SizedBox(
                        width: railWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.onSurface,
                            border: Border(
                              right: BorderSide(
                                color: AppTheme.outline.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              railPaddingH,
                              railPaddingV,
                              railPaddingH,
                              railPaddingV,
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: sidebarMaxWidth,
                                ),
                                child: _ShellSidebar(
                                  activePage: activePage,
                                  onNavigate: onNavigate,
                                  onLogout: onLogout,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          _ShellHeader(
                            compact: compact,
                            activePage: activePage,
                            onMenuTap: () =>
                                scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              key: ValueKey<AppPage>(activePage),
                              padding: EdgeInsets.fromLTRB(
                                contentHorizontalPadding,
                                24,
                                contentHorizontalPadding,
                                28,
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1380,
                                  ),
                                  child: _PageViewport(
                                    activePage: activePage,
                                    onNavigate: onNavigate,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    switch (activePage) {
      case AppPage.dashboard:
        return const DashboardPage();
      case AppPage.upload:
        return UploadPage(onNavigate: onNavigate);
      case AppPage.taskBuilder:
        return TaskBuilderPage(onNavigate: onNavigate);
      case AppPage.progress:
        return ProgressPage(onNavigate: onNavigate);
      case AppPage.results:
        return const ResultsPage();
      case AppPage.history:
        return HistoryPage(onNavigate: onNavigate);
      case AppPage.requestDetail:
        return const RequestDetailPage();
      case AppPage.nodes:
        return const NodesPage();
      case AppPage.logs:
        return const LogsPage();
      case AppPage.settings:
        return const SettingsPage();
    }
  }
}

class _ShellSidebar extends StatelessWidget {
  const _ShellSidebar({
    this.dropdownMode = false,
    required this.activePage,
    required this.onNavigate,
    required this.onLogout,
  });

  final bool dropdownMode;
  final AppPage activePage;
  final ValueChanged<AppPage> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 324;
        final bool shortHeight = constraints.maxHeight < 760;
        final Color shellBorder = dropdownMode
            ? AppTheme.outline.withValues(alpha: 0.5)
            : AppTheme.outlineVariant;
        final Color workspaceLabel = dropdownMode
            ? AppTheme.surfaceContainer.withValues(alpha: 0.78)
            : AppTheme.onSurfaceVariant;
        final List<Color> shellGradient = dropdownMode
            ? <Color>[
                AppTheme.onSurface,
                Color.alphaBlend(
                  AppTheme.secondary.withValues(alpha: 0.08),
                  AppTheme.onSurface,
                ),
                Color.alphaBlend(
                  AppTheme.surfaceMuted.withValues(alpha: 0.06),
                  AppTheme.onSurface,
                ),
              ]
            : <Color>[
                AppTheme.surface,
                AppTheme.surface,
                AppTheme.surfaceContainer.withValues(alpha: 0.82),
              ];
        final EdgeInsets shellPadding = EdgeInsets.fromLTRB(
          narrow ? 14 : 22,
          narrow ? 14 : 22,
          narrow ? 12 : 22,
          narrow ? 14 : 20,
        );
        final EdgeInsets cardPadding = EdgeInsets.all(narrow ? 14 : 18);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: shellGradient.first,
            border: Border.all(color: shellBorder),
            borderRadius: BorderRadius.circular(34),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: shellGradient,
              stops: <double>[0, 0.38, 1],
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: Padding(
            padding: shellPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    key: const PageStorageKey<String>('shell-sidebar-scroll'),
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(right: narrow ? 2 : 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _SidebarOverviewCard(
                          narrow: narrow,
                          cardPadding: cardPadding,
                        ),
                        SizedBox(height: shortHeight ? 12 : 14),
                        _SidebarHealthCard(
                          narrow: narrow,
                          cardPadding: cardPadding,
                        ),
                        SizedBox(height: shortHeight ? 18 : 24),
                        Text(
                          'WORKSPACE',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                letterSpacing: narrow ? 2.0 : 2.4,
                                color: workspaceLabel,
                              ),
                        ),
                        const SizedBox(height: 12),
                        for (int index = 0; index < shellPages.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == shellPages.length - 1 ? 0 : 6,
                            ),
                            child: Builder(
                              builder: (BuildContext context) {
                                final AppPage page = shellPages[index];
                                final bool active =
                                    page == activePage ||
                                    (activePage == AppPage.requestDetail &&
                                        page == AppPage.history);

                                return _SidebarTile(
                                  label: page.label,
                                  icon: page.icon,
                                  active: active,
                                  onTap: () => onNavigate(page),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: shortHeight ? 10 : 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign out'),
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

class _SidebarOverviewCard extends StatelessWidget {
  const _SidebarOverviewCard({required this.narrow, required this.cardPadding});

  final bool narrow;
  final EdgeInsets cardPadding;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: narrow ? 26 : 30,
      padding: EdgeInsets.zero,
      color: AppTheme.white,
      shadow: AppTheme.softShadow,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -28,
            right: -24,
            child: IgnorePointer(
              child: Container(
                width: narrow ? 92 : 116,
                height: narrow ? 92 : 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppTheme.gold.withValues(alpha: 0.06),
                      AppTheme.gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (narrow)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[_SidebarConsoleTag()],
                  )
                else
                  Row(children: <Widget>[const _SidebarConsoleTag()]),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(narrow ? 16 : 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceRaised,
                    borderRadius: BorderRadius.circular(narrow ? 22 : 24),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: narrow ? 54 : 60,
                        child: const LuminousLogo(
                          tone: LuminousBrandTone.onLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Creative operations workspace',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.slate,
                          letterSpacing: narrow ? 1.8 : 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Premium operational control for asset-heavy teams.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Keep uploads, reviews and delivery moving inside one calm, easy-to-read workspace.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.navy.withValues(alpha: 0.76),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints metricConstraints) {
                        final double halfWidth =
                            (metricConstraints.maxWidth - 8) / 2;

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            SizedBox(
                              width: halfWidth,
                              child: const _SidebarMetricPill(
                                label: 'Nodes',
                                value: '08',
                                icon: Icons.dns_outlined,
                              ),
                            ),
                            SizedBox(
                              width: halfWidth,
                              child: const _SidebarMetricPill(
                                label: 'Throughput',
                                value: '64/min',
                                icon: Icons.show_chart_rounded,
                              ),
                            ),
                            SizedBox(
                              width: metricConstraints.maxWidth,
                              child: const _SidebarMetricPill(
                                label: 'Median SLA',
                                value: '3.8s',
                                icon: Icons.bolt_rounded,
                              ),
                            ),
                          ],
                        );
                      },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHealthCard extends StatelessWidget {
  const _SidebarHealthCard({required this.narrow, required this.cardPadding});

  final bool narrow;
  final EdgeInsets cardPadding;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: narrow ? 24 : 26,
      color: AppTheme.white,
      padding: cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (narrow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SidebarHealthCopy(narrow: narrow),
                const SizedBox(height: 12),
                const _SidebarLivePill(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _SidebarHealthCopy(narrow: narrow)),
                const SizedBox(width: 12),
                const _SidebarLivePill(),
              ],
            ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.dns_outlined,
                      size: 16,
                      color: AppTheme.ink,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '8 nodes live',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressLine(
                  value: 0.72,
                  color: AppTheme.orange,
                  background: AppTheme.sand.withValues(alpha: 0.34),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.show_chart_rounded,
                      size: 16,
                      color: AppTheme.slate,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '64/min throughput',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ],
                ),
              ],
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
    final DateTime now = DateTime.now();
    final String weekday = _weekdayName(now.weekday);
    final String today = '${_monthName(now.month)} ${now.day}, ${now.year}';

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 28,
        18,
        compact ? 16 : 28,
        18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppTheme.navy,
            Color.alphaBlend(
              AppTheme.secondary.withValues(alpha: 0.12),
              AppTheme.navy,
            ),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.outline.withValues(alpha: 0.45)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -16,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 1060;

          final Widget titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                activePage.label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.surfaceContainer.withValues(alpha: 0.88),
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  _pageHeadline(activePage),
                  style: AppTheme.displayStyle(
                    context,
                    size: compact ? 28 : 32,
                    color: AppTheme.sand,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  _pageSummary(activePage),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.sand.withValues(alpha: 0.78),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (compact)
                    IconButton(
                      onPressed: onMenuTap,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainer,
                        foregroundColor: AppTheme.navy,
                        side: BorderSide(color: AppTheme.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radii.md,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  if (compact) const SizedBox(width: 12),
                  Expanded(child: titleBlock),
                  if (!stacked) ...<Widget>[
                    const SizedBox(width: 20),
                    _HeaderContextCard(weekday: weekday, today: today),
                    const SizedBox(width: 12),
                    const _HealthBadge(),
                    const SizedBox(width: 12),
                  ],
                  const _NotificationButton(),
                  const SizedBox(width: 12),
                  const _ProfilePill(),
                ],
              ),
              const SizedBox(height: 18),
              if (stacked) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _HeaderContextCard(weekday: weekday, today: today),
                    ),
                    const SizedBox(width: 12),
                    const _HealthBadge(compact: true),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: <Widget>[
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(AppTheme.radii.lg),
                        border: Border.all(
                          color: AppTheme.outline.withValues(alpha: 0.4),
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search queues, assets, requests, nodes...',
                          filled: true,
                          fillColor: Colors.transparent,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: const Icon(Icons.tune_rounded),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  if (!stacked) ...<Widget>[
                    const SizedBox(width: 14),
                    const _HeaderPulsePill(),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(compact ? 18 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.monitor_heart_outlined,
            size: 18,
            color: AppTheme.orange,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Workspace ready',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppTheme.navy),
              ),
              if (!compact)
                Text(
                  'Stable, calm and synced',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.navy.withValues(alpha: 0.72),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            fixedSize: const Size(48, 48),
            backgroundColor: AppTheme.surfaceContainer,
            foregroundColor: AppTheme.navy,
            side: BorderSide(color: AppTheme.outline),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppTheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'Alex Morgan',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                'Operations lead',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.onSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.surfaceContainer,
            ),
          ),
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
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppTheme.surfaceRaised : AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: active ? AppTheme.secondary : AppTheme.outlineVariant,
            ),
            boxShadow: active ? AppTheme.softShadow : const <BoxShadow>[],
          ),
          child: Row(
            children: <Widget>[
              if (active)
                Container(
                  width: 4,
                  height: 28,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.onSurface
                      : AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: active ? AppTheme.surfaceContainer : AppTheme.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.navy.withValues(alpha: 0.92),
                  ),
                ),
              ),
              if (active)
                const Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: AppTheme.navy,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarConsoleTag extends StatelessWidget {
  const _SidebarConsoleTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Text(
        'WORKSPACE OVERVIEW',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.navy,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _SidebarHealthCopy extends StatelessWidget {
  const _SidebarHealthCopy({required this.narrow});

  final bool narrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'WORKFLOW HEALTH',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: narrow ? 2.0 : 2.4,
            color: AppTheme.slate,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Clear and on track',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _SidebarLivePill extends StatelessWidget {
  const _SidebarLivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Live',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.navy),
          ),
        ],
      ),
    );
  }
}

class _SidebarMetricPill extends StatelessWidget {
  const _SidebarMetricPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: AppTheme.sapphire),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppTheme.ink),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderContextCard extends StatelessWidget {
  const _HeaderContextCard({required this.weekday, required this.today});

  final String weekday;
  final String today;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            weekday.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.slate,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(today, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _HeaderPulsePill extends StatelessWidget {
  const _HeaderPulsePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.bolt_rounded, size: 18, color: AppTheme.navy),
          const SizedBox(width: 8),
          Text(
            'Updates synced',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.navy),
          ),
        ],
      ),
    );
  }
}

String _weekdayName(int weekday) {
  const List<String> weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return weekdays[weekday - 1];
}

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
    case AppPage.dashboard:
      return 'Workspace at a glance';
    case AppPage.upload:
      return 'Bring new work in';
    case AppPage.taskBuilder:
      return 'Build a cleaner flow';
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
    case AppPage.dashboard:
      return 'A clear overview of pace, pending work and overall workspace rhythm.';
    case AppPage.upload:
      return 'Stage new assets and validate them before they move into review.';
    case AppPage.taskBuilder:
      return 'Set rules, presets and handoff steps without adding visual clutter.';
    case AppPage.progress:
      return 'Track active work, timing and blockers in one calm place.';
    case AppPage.results:
      return 'Review outcomes, exports and exceptions without losing context.';
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
