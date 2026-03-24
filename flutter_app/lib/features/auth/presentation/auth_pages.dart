import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onForgotPassword,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onForgotPassword;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      heroTitle: 'Distributed image\nprocessing at scale',
      heroDescription:
          'Transform thousands of assets in parallel across worker nodes. Keep monitoring, QA and result delivery in one premium control surface.',
      features: const <Map<String, Object>>[
        <String, Object>{
          'icon': Icons.memory_outlined,
          'label': 'Parallel Processing',
          'desc': '8 active nodes',
        },
        <String, Object>{
          'icon': Icons.image_outlined,
          'label': 'Batch Operations',
          'desc': '1000+ images/min',
        },
      ],
      panel: AppSurface(
        radius: 32,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFFFEFB), Colors.white],
        ),
        padding: const EdgeInsets.all(38),
        shadow: AppTheme.softShadow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const LuminousLogo(
                  tone: LuminousBrandTone.onLight,
                  width: 150,
                  height: 36,
                ),
                const Spacer(),
                _AuthFormMetaPill(
                  icon: Icons.lock_outline_rounded,
                  label: 'Secure workspace',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.canvasWarm,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.borderSoft),
              ),
              child: Text(
                'LUMINOUS ACCESS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.slate,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome back',
              style: AppTheme.displayStyle(context, size: 38, height: 1),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to your Luminous workspace',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.slate,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                _AuthFormMetaPill(
                  icon: Icons.verified_user_outlined,
                  label: 'Role-based access',
                ),
                _AuthFormMetaPill(
                  icon: Icons.flash_on_outlined,
                  label: 'Fast operator entry',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _AuthFieldLabel('Email address'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'alex@luminous.io'),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const _AuthFieldLabel('Password'),
                const Spacer(),
                _InlineActionLink(
                  label: 'Forgot password?',
                  onTap: widget.onForgotPassword,
                  dark: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: '********',
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) =>
                              setState(() => _rememberMe = value ?? false),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Remember me for 30 days',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onLogin,
                child: const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: <Widget>[
                  Text(
                    "Don't have an account?",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                  _InlineActionLink(label: 'Sign up', onTap: widget.onRegister),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Divider(color: AppTheme.borderSoft, height: 1),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'Protected by enterprise-grade security',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });

  final VoidCallback onRegister;
  final VoidCallback onLogin;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _agreeToTerms = true;

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      heroTitle: 'Start processing\nimages at scale',
      heroDescription:
          'Join teams shipping catalog, editorial and campaign work faster with distributed image transformations and premium operational visibility.',
      features: const <Map<String, Object>>[
        <String, Object>{
          'icon': Icons.auto_awesome_outlined,
          'label': 'Unlimited Scale',
          'desc': 'Process millions instantly',
        },
        <String, Object>{
          'icon': Icons.flash_on_outlined,
          'label': 'Fast Processing',
          'desc': 'Auto-distributed across nodes',
        },
      ],
      panel: AppSurface(
        radius: 32,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFFFEFB), Colors.white],
        ),
        padding: const EdgeInsets.all(34),
        shadow: AppTheme.softShadow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const LuminousLogo(
                  tone: LuminousBrandTone.onLight,
                  width: 150,
                  height: 36,
                ),
                const Spacer(),
                _AuthFormMetaPill(
                  icon: Icons.group_add_outlined,
                  label: 'Team onboarding',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.canvasWarm,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.borderSoft),
              ),
              child: Text(
                'CREATE LUMINOUS ACCESS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.slate,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create account',
              style: AppTheme.displayStyle(context, size: 34, height: 1),
            ),
            const SizedBox(height: 10),
            Text(
              'Join Luminous and start processing images',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.slate,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                _AuthFormMetaPill(
                  icon: Icons.dns_outlined,
                  label: 'Distributed-ready',
                ),
                _AuthFormMetaPill(
                  icon: Icons.shield_outlined,
                  label: 'Governed access',
                ),
              ],
            ),
            const SizedBox(height: 28),
            _AuthResponsivePair(
              left: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _AuthFieldLabel('First name'),
                  SizedBox(height: 8),
                  TextField(decoration: InputDecoration(hintText: 'Alex')),
                ],
              ),
              right: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _AuthFieldLabel('Last name'),
                  SizedBox(height: 8),
                  TextField(decoration: InputDecoration(hintText: 'Morgan')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _AuthFieldLabel('Email address'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'alex@luminous.io'),
            ),
            const SizedBox(height: 16),
            const _AuthFieldLabel('Password'),
            const SizedBox(height: 8),
            TextField(
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: '********',
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _AuthFieldLabel('Confirm password'),
            const SizedBox(height: 8),
            TextField(
              obscureText: !_showConfirm,
              decoration: InputDecoration(
                hintText: '********',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  icon: Icon(
                    _showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (bool? value) =>
                      setState(() => _agreeToTerms = value ?? false),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _agreeToTerms ? widget.onRegister : null,
                child: const Text('Create account'),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: <Widget>[
                  Text(
                    'Already have an account?',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                  ),
                  _InlineActionLink(label: 'Sign in', onTap: widget.onLogin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasSoft,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AppSurface(
                padding: const EdgeInsets.all(28),
                child: _step == 3
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppTheme.successSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.success,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Password Reset',
                            style: AppTheme.displayStyle(context, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your password has been reset. You can now return to login.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.slate),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: widget.onBack,
                              child: const Text('Return to Login'),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextButton.icon(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back to login'),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Reset your password',
                            style: AppTheme.displayStyle(context, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _step == 0
                                ? 'Enter your email address to receive a password reset code.'
                                : _step == 1
                                ? 'Enter the 6-digit code we sent to your email.'
                                : 'Create a new password for your account.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.slate),
                          ),
                          const SizedBox(height: 24),
                          if (_step == 0) ...<Widget>[
                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Email address',
                                hintText: 'alex@luminous.io',
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => setState(() => _step = 1),
                                child: const Text('Send reset code'),
                              ),
                            ),
                          ],
                          if (_step == 1) ...<Widget>[
                            const TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: 'Verification code',
                                hintText: '000000',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Check your email for the code.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => setState(() => _step = 2),
                                child: const Text('Verify code'),
                              ),
                            ),
                          ],
                          if (_step == 2) ...<Widget>[
                            const TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'New password',
                                hintText: '********',
                              ),
                            ),
                            const SizedBox(height: 16),
                            const TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirm password',
                                hintText: '********',
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => setState(() => _step = 3),
                                child: const Text('Reset password'),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.heroTitle,
    required this.heroDescription,
    required this.features,
    required this.panel,
  });

  final String heroTitle;
  final String heroDescription;
  final List<Map<String, Object>> features;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool showHero = constraints.maxWidth >= 1120;
        final bool mediumCanvas = constraints.maxWidth >= 760;
        final double compactMaxWidth = mediumCanvas ? 700 : 560;

        return Scaffold(
          backgroundColor: AppTheme.canvasSoft,
          body: SafeArea(
            child: showHero
                ? Padding(
                    padding: const EdgeInsets.all(18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Color(0xFFFFFEFB), Color(0xFFF8FBFF)],
                        ),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(color: AppTheme.borderSoft),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 12,
                              child: _AuthHeroPane(
                                heroTitle: heroTitle,
                                heroDescription: heroDescription,
                                features: features,
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Color(0xFFF9FBFE),
                                      Colors.white,
                                    ],
                                  ),
                                  border: Border(
                                    left: BorderSide(
                                      color: AppTheme.borderSoft,
                                    ),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 36,
                                      vertical: 32,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 600,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: panel,
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
                  )
                : Stack(
                    children: <Widget>[
                      const Positioned.fill(
                        child: _AuthSceneBackground(lightMode: true),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            mediumCanvas ? 36 : 20,
                            20,
                            28,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: compactMaxWidth,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _CompactAuthHero(
                                  heroTitle: heroTitle,
                                  heroDescription: heroDescription,
                                ),
                                const SizedBox(height: 18),
                                SizedBox(width: double.infinity, child: panel),
                              ],
                            ),
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

class _AuthHeroPane extends StatelessWidget {
  const _AuthHeroPane({
    required this.heroTitle,
    required this.heroDescription,
    required this.features,
  });

  final String heroTitle;
  final String heroDescription;
  final List<Map<String, Object>> features;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0D1528),
            Color(0xFF152241),
            Color(0xFF20356A),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: _AuthSceneBackground()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    AppTheme.ink.withValues(alpha: 0.34),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 52, 56, 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const LuminousLogo(
                      tone: LuminousBrandTone.onDark,
                      width: 210,
                      height: 56,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
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
                          const SizedBox(width: 8),
                          Text(
                            'Luminous mesh online',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    heroTitle,
                    style: AppTheme.displayStyle(
                      context,
                      size: 52,
                      color: Colors.white,
                      height: 0.98,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    heroDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.75,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: features.map((Map<String, Object> item) {
                    return _AuthFeatureCard(
                      icon: item['icon']! as IconData,
                      label: item['label']! as String,
                      description: item['desc']! as String,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const <Widget>[
                    _HeroMetricPill(label: '8 nodes online'),
                    _HeroMetricPill(label: '64 img/min'),
                    _HeroMetricPill(label: '3.8s median SLA'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.gold,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Premium control surface',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Built to keep operators inside one calm workspace while workloads scale.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.74),
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactAuthHero extends StatelessWidget {
  const _CompactAuthHero({
    required this.heroTitle,
    required this.heroDescription,
  });

  final String heroTitle;
  final String heroDescription;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF0D1528),
                Color(0xFF152241),
                Color(0xFF20356A),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: _AuthSceneBackground()),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Flexible(
                          child: LuminousLogo(
                            tone: LuminousBrandTone.onDark,
                            width: 184,
                            height: 44,
                          ),
                        ),
                        const Spacer(),
                        const _HeroMetricPill(label: 'Live mesh'),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      heroTitle,
                      style: AppTheme.displayStyle(
                        context,
                        size: 34,
                        color: Colors.white,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      heroDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.6,
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
  }
}

class _AuthFeatureCard extends StatelessWidget {
  const _AuthFeatureCard({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricPill extends StatelessWidget {
  const _HeroMetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _AuthFieldLabel extends StatelessWidget {
  const _AuthFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _AuthResponsivePair extends StatelessWidget {
  const _AuthResponsivePair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: <Widget>[left, const SizedBox(height: 16), right],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: left),
            const SizedBox(width: 14),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _InlineActionLink extends StatelessWidget {
  const _InlineActionLink({
    required this.label,
    required this.onTap,
    this.dark = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: dark ? AppTheme.ink : AppTheme.goldDeep,
          ),
        ),
      ),
    );
  }
}

class _AuthFormMetaPill extends StatelessWidget {
  const _AuthFormMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppTheme.sapphire),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _AuthSceneBackground extends StatelessWidget {
  const _AuthSceneBackground({this.lightMode = false});

  final bool lightMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (lightMode)
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFF8FAFC),
                    Color(0xFFF6F4EE),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
        if (lightMode)
          Positioned(
            right: -80,
            top: -40,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.sapphire.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
        if (lightMode)
          Positioned(
            left: -60,
            bottom: -80,
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: _AnimatedNodeMesh(lightMode: lightMode),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedNodeMesh extends StatefulWidget {
  const _AnimatedNodeMesh({required this.lightMode});

  final bool lightMode;

  @override
  State<_AnimatedNodeMesh> createState() => _AnimatedNodeMeshState();
}

class _AnimatedNodeMeshState extends State<_AnimatedNodeMesh>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _NodeFieldPainter(
            lightMode: widget.lightMode,
            progress: _controller.value,
          ),
          child: child,
        );
      },
    );
  }
}

class _NodeFieldPainter extends CustomPainter {
  _NodeFieldPainter({required this.lightMode, required this.progress});

  final bool lightMode;
  final double progress;

  static const List<Offset> _baseNodes = <Offset>[
    Offset(0.08, 0.16),
    Offset(0.18, 0.24),
    Offset(0.28, 0.14),
    Offset(0.34, 0.30),
    Offset(0.46, 0.20),
    Offset(0.56, 0.34),
    Offset(0.68, 0.16),
    Offset(0.78, 0.26),
    Offset(0.88, 0.18),
    Offset(0.16, 0.58),
    Offset(0.28, 0.48),
    Offset(0.40, 0.62),
    Offset(0.56, 0.52),
    Offset(0.70, 0.68),
    Offset(0.82, 0.56),
    Offset(0.90, 0.78),
    Offset(0.24, 0.82),
    Offset(0.48, 0.82),
    Offset(0.66, 0.86),
  ];

  static const List<List<int>> _links = <List<int>>[
    <int>[0, 1],
    <int>[1, 2],
    <int>[1, 3],
    <int>[2, 4],
    <int>[3, 5],
    <int>[4, 5],
    <int>[4, 6],
    <int>[5, 7],
    <int>[6, 7],
    <int>[7, 8],
    <int>[9, 10],
    <int>[10, 11],
    <int>[10, 12],
    <int>[11, 17],
    <int>[12, 13],
    <int>[12, 14],
    <int>[13, 15],
    <int>[16, 17],
    <int>[17, 18],
    <int>[3, 10],
    <int>[5, 12],
    <int>[7, 14],
  ];

  Offset _point(Size size, int index) {
    final Offset base = _baseNodes[index];
    final double waveX =
        math.sin((progress * math.pi * 2) + (index * 0.6)) * 0.014;
    final double waveY =
        math.cos((progress * math.pi * 1.8) + (index * 0.85)) * 0.018;
    return Offset(
      (base.dx + waveX) * size.width,
      (base.dy + waveY) * size.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> points = List<Offset>.generate(
      _baseNodes.length,
      (int index) => _point(size, index),
    );

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lightMode ? 1 : 1.2
      ..color = (lightMode ? AppTheme.ink : Colors.white).withValues(
        alpha: lightMode ? 0.07 : 0.14,
      );

    final Paint accentLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppTheme.gold.withValues(alpha: lightMode ? 0.12 : 0.22);

    final Paint softNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (lightMode ? AppTheme.ink : Colors.white).withValues(
        alpha: lightMode ? 0.1 : 0.18,
      );

    final Paint brightNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.gold.withValues(alpha: lightMode ? 0.72 : 0.9);

    final Paint glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    for (final List<int> link in _links) {
      canvas.drawLine(points[link[0]], points[link[1]], linePaint);
    }

    for (int i = 0; i < 5; i += 1) {
      final int startIndex = (i * 3) % points.length;
      final int endIndex = (startIndex + 4) % points.length;
      canvas.drawLine(points[startIndex], points[endIndex], accentLinePaint);
    }

    for (int i = 0; i < points.length; i += 1) {
      final Offset point = points[i];
      final bool accent = i % 4 == 0 || i == 7 || i == 13;

      if (accent) {
        glowPaint.color = AppTheme.gold.withValues(
          alpha: lightMode ? 0.12 : 0.2,
        );
        canvas.drawCircle(point, 12, glowPaint);
      }

      canvas.drawCircle(point, accent ? 4.2 : 3.2, softNodePaint);
      canvas.drawCircle(
        point,
        accent ? 2.3 : 1.6,
        accent ? brightNodePaint : softNodePaint,
      );
    }

    for (int i = 0; i < 18; i += 1) {
      final double seed = i / 18;
      final double dx =
          (math.sin((progress * math.pi * 2) + (seed * 20)) * 0.05) + seed;
      final double dy =
          (math.cos((progress * math.pi * 1.6) + (seed * 17)) * 0.06) +
          ((i % 6) / 6) * 0.9;
      final Offset point = Offset(
        (dx % 1) * size.width,
        (dy % 1) * size.height,
      );
      canvas.drawCircle(
        point,
        1.1,
        Paint()
          ..color = (lightMode ? AppTheme.slate : Colors.white).withValues(
            alpha: lightMode ? 0.12 : 0.2,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NodeFieldPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lightMode != lightMode;
  }
}
