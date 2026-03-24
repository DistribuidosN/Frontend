import 'dart:math' as math;

import 'package:flutter/material.dart';
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
  bool _isAuthenticated = false;
  AuthView _authView = AuthView.login;
  AppPage _activePage = AppPage.dashboard;

  void _handleLogin() {
    setState(() {
      _isAuthenticated = true;
      _activePage = AppPage.dashboard;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _authView = AuthView.login;
      _activePage = AppPage.dashboard;
    });
  }

  void _navigate(AppPage page) {
    setState(() {
      _activePage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luminous',
      theme: AppTheme.lightTheme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _isAuthenticated
            ? _AppShell(
                key: const ValueKey<String>('shell'),
                activePage: _activePage,
                onNavigate: _navigate,
                onLogout: _handleLogout,
              )
            : _buildAuthView(),
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
          onRegister: _handleLogin,
          onLogin: () => setState(() => _authView = AuthView.login),
        );
      case AuthView.forgot:
        return ForgotPasswordPage(
          key: const ValueKey<String>('forgot'),
          onBack: () => setState(() => _authView = AuthView.login),
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
        final bool compact = constraints.maxWidth < 1180;

        return Scaffold(
          key: scaffoldKey,
          drawer: compact
              ? Drawer(
                  width: math.min(360, constraints.maxWidth - 12),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _ShellSidebar(
                        activePage: activePage,
                        onNavigate: (AppPage page) {
                          Navigator.of(context).maybePop();
                          onNavigate(page);
                        },
                        onLogout: onLogout,
                      ),
                    ),
                  ),
                )
              : null,
          body: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFFF5F3EC),
                        Color(0xFFF7FAFF),
                        Colors.white,
                      ],
                      stops: <double>[0, 0.22, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -140,
                top: 90,
                child: IgnorePointer(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -120,
                top: -40,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.sapphire.withValues(alpha: 0.07),
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
                        width: 316,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                          child: _ShellSidebar(
                            activePage: activePage,
                            onNavigate: onNavigate,
                            onLogout: onLogout,
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
                              padding: EdgeInsets.fromLTRB(
                                compact ? 16 : 28,
                                24,
                                compact ? 16 : 28,
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
    required this.activePage,
    required this.onNavigate,
    required this.onLogout,
  });

  final AppPage activePage;
  final ValueChanged<AppPage> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 255;
        final EdgeInsets shellPadding = EdgeInsets.all(narrow ? 16 : 18);
        final EdgeInsets cardPadding = EdgeInsets.all(narrow ? 14 : 16);

        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderSoft),
            borderRadius: BorderRadius.circular(36),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFFFFFCF6),
                Color(0xFFFFFFFF),
                Color(0xFFF8FBFF),
              ],
              stops: <double>[0, 0.38, 1],
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: Padding(
            padding: shellPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSurface(
                  radius: narrow ? 26 : 30,
                  padding: cardPadding,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFFFFEFB), Color(0xFFF3F8FF)],
                  ),
                  shadow: AppTheme.softShadow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppTheme.borderSoft),
                        ),
                        child: Text(
                          'OPERATOR CONSOLE',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.slate,
                                letterSpacing: 1.8,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: LuminousLogo(
                                tone: LuminousBrandTone.onLight,
                                width: narrow ? 152 : 176,
                                height: narrow ? 36 : 42,
                              ),
                            ),
                          ),
                          SizedBox(width: narrow ? 10 : 12),
                          Container(
                            width: narrow ? 44 : 50,
                            height: narrow ? 44 : 50,
                            decoration: BoxDecoration(
                              color: AppTheme.canvasSoft,
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(
                                narrow ? 16 : 18,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(9),
                              child: LuminousLogo(
                                tone: LuminousBrandTone.onLight,
                                iconOnly: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'DISTRIBUTED IMAGE SYSTEM',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.slate,
                          letterSpacing: narrow ? 2.0 : 2.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Control and monitor every workflow from one premium surface.',
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const <Widget>[
                          _SidebarMetricPill(
                            label: 'Nodes',
                            value: '08',
                            icon: Icons.dns_outlined,
                          ),
                          _SidebarMetricPill(
                            label: 'Throughput',
                            value: '64/min',
                            icon: Icons.show_chart_rounded,
                          ),
                          _SidebarMetricPill(
                            label: 'Median SLA',
                            value: '3.8s',
                            icon: Icons.bolt_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppSurface(
                  radius: narrow ? 24 : 26,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFFDFEFE), Color(0xFFF6FBF8)],
                  ),
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'CLUSTER HEALTH',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        letterSpacing: narrow ? 2.0 : 2.4,
                                        color: AppTheme.slate,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Balanced and active',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successSoft,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppTheme.success.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Live',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: AppTheme.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderSoft),
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
                              color: AppTheme.success,
                              background: AppTheme.success.withValues(
                                alpha: 0.12,
                              ),
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
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.slate),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'WORKSPACE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: narrow ? 2.0 : 2.4,
                    color: AppTheme.slate,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: shellPages.length,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (BuildContext context, int index) {
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
                const SizedBox(height: 14),
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
        20,
        compact ? 16 : 28,
        22,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderSoft)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xF9FFFFFF), Color(0xF3F7FCFF)],
        ),
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
                  color: AppTheme.slate,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _pageHeadline(activePage),
                style: AppTheme.displayStyle(context, size: compact ? 28 : 34),
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
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search queues, assets, requests, nodes...',
                        prefixIcon: Icon(Icons.search_rounded),
                        suffixIcon: Icon(Icons.tune_rounded),
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
        color: compact ? Colors.white : const Color(0xFFF7FEE7),
        border: Border.all(
          color: compact ? AppTheme.borderSoft : const Color(0xFFD9F99D),
        ),
        borderRadius: BorderRadius.circular(compact ? 18 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.monitor_heart_outlined,
            size: 18,
            color: Color(0xFF166534),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'System Healthy',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF166534),
                ),
              ),
              if (!compact)
                Text(
                  'Queue stable and under SLA',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF3F6212),
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
          style: IconButton.styleFrom(fixedSize: const Size(48, 48)),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppTheme.gold,
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
        color: Colors.white,
        border: Border.all(color: AppTheme.borderSoft),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppTheme.ink, AppTheme.sapphire],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.gold,
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
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[AppTheme.ink, AppTheme.inkSoft],
                  )
                : null,
            color: active ? null : Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: active ? AppTheme.ink : AppTheme.borderSoft,
            ),
            boxShadow: active ? AppTheme.cardShadow : const <BoxShadow>[],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppTheme.canvasWarm,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: active ? AppTheme.gold : AppTheme.slate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: active ? Colors.white : AppTheme.slate,
                  ),
                ),
              ),
              if (active)
                const Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: Colors.white70,
                ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppTheme.sapphire),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppTheme.ink),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
              ),
            ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSoft),
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
        color: AppTheme.sapphireSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.sapphire.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.bolt_rounded, size: 18, color: AppTheme.sapphire),
          const SizedBox(width: 8),
          Text(
            'Live pulse synced',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.sapphire),
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
      return 'Operations at a glance';
    case AppPage.upload:
      return 'Bring new image batches in';
    case AppPage.taskBuilder:
      return 'Shape the processing flow';
    case AppPage.progress:
      return 'Track active workloads live';
    case AppPage.results:
      return 'Review delivered outputs';
    case AppPage.history:
      return 'Inspect past execution lanes';
    case AppPage.requestDetail:
      return 'Inspect request details';
    case AppPage.nodes:
      return 'Observe worker capacity';
    case AppPage.logs:
      return 'Read platform activity';
    case AppPage.settings:
      return 'Tune workspace behavior';
  }
}

String _pageSummary(AppPage page) {
  switch (page) {
    case AppPage.dashboard:
      return 'A premium operational view of throughput, queue pressure, and cluster calm.';
    case AppPage.upload:
      return 'Stage new workloads and validate assets before they hit the queue.';
    case AppPage.taskBuilder:
      return 'Compose presets, routing, and delivery rules with clean guardrails.';
    case AppPage.progress:
      return 'Keep an eye on active jobs, pacing, and workload health in one place.';
    case AppPage.results:
      return 'Review outcomes, exports, and surfaced exceptions without losing context.';
    case AppPage.history:
      return 'Audit prior requests and compare how the system behaved over time.';
    case AppPage.requestDetail:
      return 'Zoom into one request and inspect every important operational signal.';
    case AppPage.nodes:
      return 'See how each worker is carrying load, risk, and available recovery room.';
    case AppPage.logs:
      return 'Surface system events with enough clarity to spot patterns quickly.';
    case AppPage.settings:
      return 'Adjust workspace rules, defaults, and operator-facing behavior.';
  }
}
