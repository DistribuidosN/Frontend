import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class _AuthPalette {
  static const Color navy = Color(0xFF003049);
  static const Color red = Color(0xFFD62828);
  static const Color orange = Color(0xFFF77F00);
  static const Color gold = Color(0xFFFCBF49);
  static const Color sand = Color(0xFFEAE2B7);
}

ThemeData _authFormTheme(BuildContext context) {
  final ThemeData base = Theme.of(context);

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _AuthPalette.sand,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _AuthPalette.gold, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _AuthPalette.gold, width: 1.2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _AuthPalette.gold, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _AuthPalette.red, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _AuthPalette.red, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _AuthPalette.red, width: 1.6),
      ),
      hintStyle: base.textTheme.bodyMedium?.copyWith(
        color: _AuthPalette.navy.withValues(alpha: 0.56),
      ),
      labelStyle: base.textTheme.bodyMedium?.copyWith(
        color: _AuthPalette.navy.withValues(alpha: 0.88),
      ),
      prefixIconColor: _AuthPalette.navy,
      suffixIconColor: _AuthPalette.navy,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _AuthPalette.red,
        foregroundColor: _AuthPalette.sand,
        disabledBackgroundColor: _AuthPalette.orange,
        disabledForegroundColor: _AuthPalette.sand,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: base.textTheme.labelLarge,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _AuthPalette.navy,
        backgroundColor: _AuthPalette.sand,
        side: const BorderSide(color: _AuthPalette.gold, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: base.textTheme.labelLarge,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        return states.contains(WidgetState.selected)
            ? _AuthPalette.red
            : _AuthPalette.sand;
      }),
      checkColor: WidgetStateProperty.all<Color>(_AuthPalette.sand),
      side: const BorderSide(color: _AuthPalette.orange, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    ),
  );
}

class _AuthPanelTheme extends StatelessWidget {
  const _AuthPanelTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(data: _authFormTheme(context), child: child);
  }
}

class _AuthBrandMark extends StatelessWidget {
  const _AuthBrandMark({required this.darkSurface});

  final bool darkSurface;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: LuminousLogo(
        tone: darkSurface
            ? LuminousBrandTone.onDark
            : LuminousBrandTone.onLight,
        height: 62,
        fit: BoxFit.contain,
      ),
    );
  }
}

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
      heroTitle: 'Image workflows,\nbeautifully organized',
      heroDescription:
          'Keep uploads, approvals and delivery review inside one calm workspace built around your team and your brand.',
      heroEyebrow: 'ENFOK WORKSPACE',
      heroStatusLabel: 'Secure workspace',
      lightweightHero: true,
      features: const <Map<String, Object>>[
        <String, Object>{
          'icon': Icons.dashboard_customize_outlined,
          'label': 'Clear workspace',
          'desc': 'One place for uploads, presets and review',
        },
        <String, Object>{
          'icon': Icons.auto_awesome_outlined,
          'label': 'Thoughtful automation',
          'desc': 'Useful defaults without visual noise',
        },
      ],
      panel: _AuthPanelTheme(
        child: Container(
          padding: const EdgeInsets.all(38),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _AuthPalette.navy.withValues(alpha: 0.08),
              width: 1.1,
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[const _AuthBrandMark(darkSurface: false)]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _AuthPalette.sand,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _AuthPalette.gold.withValues(alpha: 0.72),
                    width: 1.1,
                  ),
                ),
                child: Text(
                  'WORKSPACE ACCESS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _AuthPalette.navy,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Welcome back',
                style: AppTheme.displayStyle(
                  context,
                  size: 38,
                  height: 1,
                  color: _AuthPalette.navy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign in to your Enfok workspace',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _AuthPalette.navy,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              const _AuthFieldLabel('Email address'),
              const SizedBox(height: 8),
              const TextField(
                style: TextStyle(color: _AuthPalette.navy),
                decoration: InputDecoration(hintText: 'alex@enfok.co'),
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
                style: const TextStyle(color: _AuthPalette.navy),
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
                                  ?.copyWith(color: _AuthPalette.navy),
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
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: _AuthPalette.navy.withValues(alpha: 0.58),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Protected by enterprise-grade security',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _AuthPalette.navy.withValues(alpha: 0.68),
                      ),
                    ),
                  ),
                ],
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
                      ).textTheme.bodySmall?.copyWith(color: _AuthPalette.navy),
                    ),
                    _InlineActionLink(
                      label: 'Sign up',
                      onTap: widget.onRegister,
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
      heroTitle: 'Build a workspace\nthat feels clear',
      heroDescription:
          'Create a clean Enfok workspace for uploads, reviews and delivery with a calmer, more polished experience from day one.',
      features: const <Map<String, Object>>[
        <String, Object>{
          'icon': Icons.people_alt_outlined,
          'label': 'Team-ready',
          'desc': 'Shared access with a cleaner daily flow',
        },
        <String, Object>{
          'icon': Icons.tune_outlined,
          'label': 'Flexible presets',
          'desc': 'Shape image rules without friction',
        },
      ],
      panel: _AuthPanelTheme(
        child: Container(
          padding: const EdgeInsets.all(34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _AuthPalette.navy.withValues(alpha: 0.08),
              width: 1.1,
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const _AuthBrandMark(darkSurface: false),
                  const Spacer(),
                  const _AuthFormMetaPill(
                    icon: Icons.group_add_outlined,
                    label: 'Quick setup',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _AuthPalette.gold,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _AuthPalette.orange, width: 1.1),
                ),
                child: Text(
                  'CREATE ENFOK ACCESS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _AuthPalette.navy,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Create account',
                style: AppTheme.displayStyle(
                  context,
                  size: 34,
                  height: 1,
                  color: _AuthPalette.navy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your Enfok workspace and invite your team',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _AuthPalette.navy,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const <Widget>[
                  _AuthFormMetaPill(
                    icon: Icons.dashboard_customize_outlined,
                    label: 'Clean workflow',
                  ),
                  _AuthFormMetaPill(
                    icon: Icons.shield_outlined,
                    label: 'Private access',
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
                    TextField(
                      style: TextStyle(color: _AuthPalette.navy),
                      decoration: InputDecoration(hintText: 'Alex'),
                    ),
                  ],
                ),
                right: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _AuthFieldLabel('Last name'),
                    SizedBox(height: 8),
                    TextField(
                      style: TextStyle(color: _AuthPalette.navy),
                      decoration: InputDecoration(hintText: 'Morgan'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _AuthFieldLabel('Email address'),
              const SizedBox(height: 8),
              const TextField(
                style: TextStyle(color: _AuthPalette.navy),
                decoration: InputDecoration(hintText: 'alex@enfok.co'),
              ),
              const SizedBox(height: 16),
              const _AuthFieldLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(color: _AuthPalette.navy),
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
                style: const TextStyle(color: _AuthPalette.navy),
                obscureText: !_showConfirm,
                decoration: InputDecoration(
                  hintText: '********',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _showConfirm = !_showConfirm),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _AuthPalette.navy,
                        ),
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
                      ).textTheme.bodySmall?.copyWith(color: _AuthPalette.navy),
                    ),
                    _InlineActionLink(label: 'Sign in', onTap: widget.onLogin),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _AuthSceneBackground(lightMode: true)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _AuthPanelTheme(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _AuthPalette.navy.withValues(alpha: 0.08),
                          width: 1.1,
                        ),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: _step == 3
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const _AuthBrandMark(darkSurface: false),
                                const SizedBox(height: 26),
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: _AuthPalette.gold,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _AuthPalette.orange,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: _AuthPalette.navy,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Password reset',
                                  style: AppTheme.displayStyle(
                                    context,
                                    size: 30,
                                    color: _AuthPalette.navy,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Your access has been updated. Return to login and continue into the control surface.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: _AuthPalette.navy,
                                        height: 1.65,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: widget.onBack,
                                    child: const Text('Return to login'),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const _AuthBrandMark(darkSurface: false),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: widget.onBack,
                                      style: TextButton.styleFrom(
                                        foregroundColor: _AuthPalette.red,
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                      ),
                                      label: const Text('Back to login'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _AuthPalette.gold,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _AuthPalette.orange,
                                      width: 1.1,
                                    ),
                                  ),
                                  child: Text(
                                    'ACCESS RECOVERY',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: _AuthPalette.navy,
                                          letterSpacing: 2,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Reset your password',
                                  style: AppTheme.displayStyle(
                                    context,
                                    size: 32,
                                    color: _AuthPalette.navy,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _step == 0
                                      ? 'Enter the email address tied to your workspace and we will send a recovery code.'
                                      : _step == 1
                                      ? 'Enter the 6-digit code that just reached your inbox.'
                                      : 'Create a new password for your Enfok account.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: _AuthPalette.navy,
                                        height: 1.65,
                                      ),
                                ),
                                const SizedBox(height: 22),
                                if (_step == 0) ...<Widget>[
                                  const _AuthFieldLabel('Email address'),
                                  const SizedBox(height: 8),
                                  const TextField(
                                    style: TextStyle(color: _AuthPalette.navy),
                                    decoration: InputDecoration(
                                      hintText: 'alex@enfok.co',
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () =>
                                          setState(() => _step = 1),
                                      child: const Text('Send reset code'),
                                    ),
                                  ),
                                ],
                                if (_step == 1) ...<Widget>[
                                  const _AuthFieldLabel('Verification code'),
                                  const SizedBox(height: 8),
                                  const TextField(
                                    style: TextStyle(color: _AuthPalette.navy),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '000000',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Check your email for the verification code.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: _AuthPalette.navy),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () =>
                                          setState(() => _step = 2),
                                      child: const Text('Verify code'),
                                    ),
                                  ),
                                ],
                                if (_step == 2) ...<Widget>[
                                  const _AuthFieldLabel('New password'),
                                  const SizedBox(height: 8),
                                  const TextField(
                                    style: TextStyle(color: _AuthPalette.navy),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: '********',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const _AuthFieldLabel('Confirm password'),
                                  const SizedBox(height: 8),
                                  const TextField(
                                    style: TextStyle(color: _AuthPalette.navy),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: '********',
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () =>
                                          setState(() => _step = 3),
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
          ],
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
    this.heroEyebrow = 'ENFOK WORKSPACE',
    this.heroStatusLabel = 'Visual mesh active',
    this.lightweightHero = false,
  });

  final String heroTitle;
  final String heroDescription;
  final List<Map<String, Object>> features;
  final Widget panel;
  final String heroEyebrow;
  final String heroStatusLabel;
  final bool lightweightHero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool showHero = constraints.maxWidth >= 1120;
        final bool mediumCanvas = constraints.maxWidth >= 760;
        final double compactMaxWidth = mediumCanvas ? 700 : 560;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                const Positioned.fill(
                  child: _AuthSceneBackground(lightMode: true),
                ),
                showHero
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                              color: _AuthPalette.navy.withValues(alpha: 0.08),
                              width: 1.1,
                            ),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  flex: 11,
                                  child: _AuthHeroPane(
                                    heroTitle: heroTitle,
                                    heroDescription: heroDescription,
                                    features: features,
                                    heroEyebrow: heroEyebrow,
                                    heroStatusLabel: heroStatusLabel,
                                    lightweightHero: lightweightHero,
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        left: BorderSide(
                                          color: _AuthPalette.navy.withValues(
                                            alpha: 0.08,
                                          ),
                                          width: 1.1,
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
                    : Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            mediumCanvas ? 40 : 24,
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
                                  heroEyebrow: heroEyebrow,
                                  heroStatusLabel: heroStatusLabel,
                                  lightweightHero: lightweightHero,
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
    required this.heroEyebrow,
    required this.heroStatusLabel,
    required this.lightweightHero,
  });

  final String heroTitle;
  final String heroDescription;
  final List<Map<String, Object>> features;
  final String heroEyebrow;
  final String heroStatusLabel;
  final bool lightweightHero;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Positioned.fill(child: _AuthSceneBackground(lightMode: true)),
          Positioned(
            left: -60,
            bottom: -80,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _AuthPalette.sand.withValues(alpha: 0.36),
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: -30,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _AuthPalette.gold.withValues(alpha: 0.24),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.92),
                    _AuthPalette.sand.withValues(alpha: 0.36),
                    Colors.white.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxHeight < 760;
              final bool ultraCompact = constraints.maxHeight < 660;
              final bool useScroll = constraints.maxHeight < 620;
              final double horizontalPadding = compact ? 40 : 56;
              final double verticalPadding = ultraCompact
                  ? 28
                  : (compact ? 38 : 52);
              final double titleSize = ultraCompact ? 40 : (compact ? 46 : 54);
              final double titleGap = compact ? 18 : 24;
              final double descriptionGap = compact ? 12 : 18;
              final double featuresGap = compact ? 18 : 30;
              final double metricsGap = compact ? 12 : 18;
              final double promoGap = compact ? 14 : 22;
              final double featureSpacing = compact ? 14 : 16;
              final double maxTextWidth = compact ? 520 : 560;
              final Widget highlightsShelf = Container(
                constraints: const BoxConstraints(maxWidth: 560),
                padding: EdgeInsets.all(compact ? 18 : 22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _AuthPalette.navy.withValues(alpha: 0.08),
                    width: 1.1,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _AuthPalette.navy.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                      spreadRadius: -18,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Operator highlights',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _AuthPalette.navy.withValues(alpha: 0.68),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: featureSpacing,
                      runSpacing: featureSpacing,
                      children: features.map((Map<String, Object> item) {
                        return _AuthFeatureCard(
                          icon: item['icon']! as IconData,
                          label: item['label']! as String,
                          description: item['desc']! as String,
                          lightMode: true,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );

              final Widget content = Column(
                mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const _AuthBrandMark(darkSurface: false),
                      const Spacer(),
                      if (!lightweightHero)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 12 : 14,
                            vertical: compact ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _AuthPalette.gold.withValues(alpha: 0.44),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: _AuthPalette.gold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                heroStatusLabel,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: _AuthPalette.navy),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: titleGap),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _AuthPalette.sand,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _AuthPalette.gold.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      heroEyebrow,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _AuthPalette.navy,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 16 : 18),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxTextWidth),
                    child: Text(
                      heroTitle,
                      style: AppTheme.displayStyle(
                        context,
                        size: titleSize,
                        color: _AuthPalette.navy,
                        height: 0.96,
                      ),
                    ),
                  ),
                  SizedBox(height: descriptionGap),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxTextWidth),
                    child: Text(
                      heroDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _AuthPalette.navy.withValues(alpha: 0.76),
                        height: compact ? 1.65 : 1.75,
                      ),
                    ),
                  ),
                  if (lightweightHero) ...<Widget>[
                    SizedBox(height: featuresGap),
                    if (!compact) const Spacer(),
                    highlightsShelf,
                  ] else ...<Widget>[
                    SizedBox(height: featuresGap),
                    Wrap(
                      spacing: featureSpacing,
                      runSpacing: featureSpacing,
                      children: features.map((Map<String, Object> item) {
                        return _AuthFeatureCard(
                          icon: item['icon']! as IconData,
                          label: item['label']! as String,
                          description: item['desc']! as String,
                          lightMode: true,
                        );
                      }).toList(),
                    ),
                  ],
                  if (!lightweightHero) ...<Widget>[
                    SizedBox(height: metricsGap),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const <Widget>[
                        _HeroMetricPill(
                          label: 'Private workspace',
                          lightMode: true,
                        ),
                        _HeroMetricPill(
                          label: 'Clean review flow',
                          lightMode: true,
                        ),
                        _HeroMetricPill(
                          label: 'Brand-ready delivery',
                          lightMode: true,
                        ),
                      ],
                    ),
                    SizedBox(height: promoGap),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: EdgeInsets.all(compact ? 16 : 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _AuthPalette.navy.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _AuthPalette.sand,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: _AuthPalette.red,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Designed for calm control',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: _AuthPalette.navy),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Built for teams that want a cleaner workspace, better handoff, and a stronger sense of polish.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: _AuthPalette.navy.withValues(
                                          alpha: 0.74,
                                        ),
                                        height: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!compact) const Spacer(),
                ],
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: useScroll
                    ? SingleChildScrollView(child: content)
                    : content,
              );
            },
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
    required this.heroEyebrow,
    required this.heroStatusLabel,
    required this.lightweightHero,
  });

  final String heroTitle;
  final String heroDescription;
  final String heroEyebrow;
  final String heroStatusLabel;
  final bool lightweightHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _AuthPalette.navy.withValues(alpha: 0.08)),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _AuthSceneBackground(lightMode: true)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Flexible(child: _AuthBrandMark(darkSurface: false)),
                      const Spacer(),
                      if (!lightweightHero)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _AuthPalette.sand,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _AuthPalette.gold.withValues(alpha: 0.48),
                            ),
                          ),
                          child: Text(
                            heroStatusLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: _AuthPalette.navy),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _AuthPalette.sand,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _AuthPalette.gold.withValues(alpha: 0.52),
                      ),
                    ),
                    child: Text(
                      heroEyebrow,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _AuthPalette.navy,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    heroTitle,
                    style: AppTheme.displayStyle(
                      context,
                      size: 34,
                      color: _AuthPalette.navy,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    heroDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _AuthPalette.navy.withValues(alpha: 0.74),
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    this.lightMode = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool lightMode;

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
            lightMode
                ? Colors.white.withValues(alpha: 0.94)
                : _AuthPalette.sand.withValues(alpha: 0.12),
            lightMode
                ? _AuthPalette.sand.withValues(alpha: 0.22)
                : _AuthPalette.gold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: lightMode
              ? _AuthPalette.navy.withValues(alpha: 0.06)
              : _AuthPalette.gold.withValues(alpha: 0.28),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightMode
                  ? _AuthPalette.sand.withValues(alpha: 0.78)
                  : _AuthPalette.red.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: lightMode ? _AuthPalette.navy : _AuthPalette.gold,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: lightMode ? _AuthPalette.navy : _AuthPalette.sand,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: lightMode
                  ? _AuthPalette.navy.withValues(alpha: 0.72)
                  : _AuthPalette.sand.withValues(alpha: 0.74),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricPill extends StatelessWidget {
  const _HeroMetricPill({required this.label, this.lightMode = false});

  final String label;
  final bool lightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: lightMode
            ? Colors.white.withValues(alpha: 0.9)
            : _AuthPalette.sand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: lightMode
              ? _AuthPalette.gold.withValues(alpha: 0.26)
              : _AuthPalette.gold.withValues(alpha: 0.28),
          width: 1.1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: lightMode ? _AuthPalette.navy : _AuthPalette.sand,
        ),
      ),
    );
  }
}

class _AuthFieldLabel extends StatelessWidget {
  const _AuthFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: _AuthPalette.navy),
    );
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
            color: dark ? _AuthPalette.red : _AuthPalette.orange,
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
        color: _AuthPalette.sand.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _AuthPalette.gold.withValues(alpha: 0.56),
          width: 1.1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: _AuthPalette.navy),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: _AuthPalette.navy),
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white,
                    _AuthPalette.sand.withValues(alpha: 0.26),
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
                  color: _AuthPalette.gold.withValues(alpha: 0.08),
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
                  color: _AuthPalette.orange.withValues(alpha: 0.05),
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
      ..color = (lightMode ? _AuthPalette.navy : _AuthPalette.sand).withValues(
        alpha: lightMode ? 0.14 : 0.16,
      );

    final Paint accentLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _AuthPalette.gold.withValues(alpha: lightMode ? 0.26 : 0.34);

    final Paint softNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (lightMode ? _AuthPalette.navy : _AuthPalette.sand).withValues(
        alpha: lightMode ? 0.18 : 0.2,
      );

    final Paint brightNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (lightMode ? _AuthPalette.orange : _AuthPalette.gold)
          .withValues(alpha: lightMode ? 0.82 : 0.92);

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
        glowPaint.color = (lightMode ? _AuthPalette.orange : _AuthPalette.red)
            .withValues(alpha: lightMode ? 0.14 : 0.22);
        canvas.drawCircle(point, 14, glowPaint);
      }

      canvas.drawCircle(point, accent ? 4.8 : 3.6, softNodePaint);
      canvas.drawCircle(
        point,
        accent ? 2.6 : 1.9,
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
        1.3,
        Paint()
          ..color = (lightMode ? _AuthPalette.orange : _AuthPalette.gold)
              .withValues(alpha: lightMode ? 0.14 : 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NodeFieldPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lightMode != lightMode;
  }
}
