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
      title: 'ImageFlow',
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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFFF6F4EE),
                  Color(0xFFF8FAFC),
                  Colors.white,
                ],
                stops: <double>[0, 0.18, 1],
              ),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!compact)
                    SizedBox(
                      width: 308,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
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
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFFFFFCF5), Colors.white, Colors.white],
              stops: <double>[0, 0.32, 1],
            ),
          ),
          child: Padding(
            padding: shellPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSurface(
                  radius: narrow ? 24 : 28,
                  padding: cardPadding,
                  shadow: AppTheme.softShadow,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: narrow ? 44 : 50,
                        height: narrow ? 44 : 50,
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(narrow ? 16 : 18),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppTheme.gold,
                        ),
                      ),
                      SizedBox(width: narrow ? 12 : 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'IMAGE PIPELINE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppTheme.slate,
                                    letterSpacing: narrow ? 2.0 : 2.4,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ImageFlow',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.displayStyle(
                                context,
                                size: narrow ? 22 : 24,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Distributed processing',
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppSurface(
                  radius: narrow ? 24 : 26,
                  color: const Color(0xFFFCFCFD),
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
                          border: Border.all(color: AppTheme.border),
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
                OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign out'),
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
  const _ShellHeader({required this.compact, required this.onMenuTap});

  final bool compact;
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
        18,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xCCE2E8F0))),
        color: Color(0xEBF8FAFC),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool narrowActions = constraints.maxWidth < 860;

          return Column(
            children: <Widget>[
              Row(
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
                  Expanded(
                    flex: compact ? 1 : 2,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search images, requests, nodes...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppTheme.slate,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!narrowActions)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          weekday.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.slate,
                                letterSpacing: 2.4,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          today,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  if (!narrowActions) const SizedBox(width: 16),
                  if (!narrowActions) const _HealthBadge(),
                  const SizedBox(width: 12),
                  const _NotificationButton(),
                  const SizedBox(width: 12),
                  const _ProfilePill(),
                ],
              ),
              if (narrowActions) ...<Widget>[
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '$weekday, $today',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ),
                    const _HealthBadge(compact: true),
                  ],
                ),
              ],
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
        color: const Color(0xFFF7FEE7),
        border: Border.all(color: const Color(0xFFD9F99D)),
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
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.slate,
            fixedSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            side: const BorderSide(color: AppTheme.border),
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
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(22),
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
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.ink,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: active ? AppTheme.ink : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppTheme.ink : Colors.transparent,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: active ? AppTheme.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                size: 20,
                color: active ? AppTheme.gold : AppTheme.slate,
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
            ],
          ),
        ),
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
