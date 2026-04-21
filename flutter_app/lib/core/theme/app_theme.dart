import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 20,
    this.xxl = 24,
    this.section = 28,
    this.page = 36,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double section;
  final double page;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? section,
    double? page,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      section: section ?? this.section,
      page: page ?? this.page,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }

    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      section: lerpDouble(section, other.section, t)!,
      page: lerpDouble(page, other.page, t)!,
    );
  }
}

@immutable
class AppRadii extends ThemeExtension<AppRadii> {
  const AppRadii({
    this.sm = 12,
    this.md = 16,
    this.lg = 20,
    this.xl = 28,
    this.pill = 999,
  });

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  @override
  AppRadii copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? pill,
  }) {
    return AppRadii(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      pill: pill ?? this.pill,
    );
  }

  @override
  AppRadii lerp(ThemeExtension<AppRadii>? other, double t) {
    if (other is! AppRadii) {
      return this;
    }

    return AppRadii(
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      pill: lerpDouble(pill, other.pill, t)!,
    );
  }
}

class AppTheme {
  static const Color background = Color(0xFFFCFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFFFFCF9);
  static const Color surfaceContainer = Color(0xFFF8F4EE);
  static const Color surfaceMuted = Color(0xFFF3EDE4);
  static const Color primary = Color(0xFF2E6F95);
  static const Color secondary = Color(0xFF4F86A6);
  static const Color tertiary = Color(0xFFF4A261);
  static const Color success = Color(0xFF2F855A);
  static const Color error = Color(0xFFB42318);
  static const Color onSurface = Color(0xFF24313F);
  static const Color onSurfaceVariant = Color(0xFF5D6B78);
  static const Color outline = Color(0xFFD7CCBF);
  static const Color outlineVariant = Color(0xFFEEE5DA);

  static const Color white = surface;
  static const Color navy = onSurface;
  static const Color red = error;
  static const Color orange = tertiary;
  static const Color gold = Color(0xFFE6B566);
  static const Color sand = surfaceContainer;
  static const Color statusGreen = success;
  static const Color ink = onSurface;
  static const Color inkSoft = onSurfaceVariant;
  static const Color slate = onSurfaceVariant;
  static const Color muted = Color(0x995D6B78);
  static const Color border = outline;
  static const Color borderSoft = outlineVariant;
  static const Color borderStrong = Color(0xFFCDBEAF);
  static const Color canvas = background;
  static const Color canvasSoft = surfaceContainer;
  static const Color canvasWarm = surfaceMuted;
  static const Color sapphire = secondary;
  static const Color sapphireSoft = Color(0xFFEAF1F6);
  static const Color goldDeep = Color(0xFFBA7A2C);
  static const Color successSoft = Color(0xFFE7F4EC);
  static const Color info = secondary;
  static const Color infoSoft = Color(0xFFEAF1F6);
  static const Color danger = error;
  static const Color dangerSoft = Color(0xFFFDEAE7);
  static const Color warning = gold;
  static const Color warningSoft = Color(0xFFFCF1DB);
  static const Color midnight = onSurface;

  static const AppSpacing spacing = AppSpacing();
  static const AppRadii radii = AppRadii();

  static ThemeData lightTheme() {
    const ColorScheme scheme = ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      error: error,
      surface: surface,
      onPrimary: white,
      onSecondary: white,
      onSurface: onSurface,
      onError: white,
      outline: outline,
      outlineVariant: outlineVariant,
    );

    final TextTheme textTheme = GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 44,
        height: 1.08,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 32,
        height: 1.12,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 28,
        height: 1.14,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 24,
        height: 1.18,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 20,
        height: 1.18,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        height: 1.6,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        height: 1.57,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        height: 1.25,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: onSurfaceVariant,
      ),
    );

    final BorderRadius fieldRadius = BorderRadius.circular(radii.md);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: NoSplash.splashFactory,
      hoverColor: secondary.withValues(alpha: 0.06),
      highlightColor: Colors.transparent,
      focusColor: secondary.withValues(alpha: 0.1),
      textTheme: textTheme,
      dividerColor: outlineVariant,
      splashColor: secondary.withValues(alpha: 0.06),
      cardColor: surface,
      extensions: const <ThemeExtension<dynamic>>[spacing, radii],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.lg),
          side: const BorderSide(color: outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: outline),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(0, 50)),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return primary.withValues(alpha: 0.45);
            }
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFF255A79);
            }
            return primary;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(white),
          overlayColor: WidgetStateProperty.all<Color>(
            white.withValues(alpha: 0.06),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radii.md),
            ),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(textTheme.labelLarge),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            return states.contains(WidgetState.hovered) ? 2 : 0;
          }),
          shadowColor: WidgetStateProperty.all<Color>(
            onSurface.withValues(alpha: 0.16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(0, 46)),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          foregroundColor: WidgetStateProperty.all<Color>(onSurface),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return surfaceMuted;
            }
            if (states.contains(WidgetState.hovered)) {
              return surfaceContainer;
            }
            return surface;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: secondary, width: 1.5);
            }
            return const BorderSide(color: outline);
          }),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radii.md),
            ),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          foregroundColor: secondary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return surface;
        }),
        checkColor: WidgetStateProperty.all<Color>(white),
        side: const BorderSide(color: outline, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.sm - 4),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: secondary,
        inactiveTrackColor: surfaceMuted,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.md),
          side: const BorderSide(color: outlineVariant),
        ),
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(44, 44)),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered)) {
              return surfaceContainer;
            }
            return surface;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(onSurface),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radii.md),
            ),
          ),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(color: outline),
          ),
        ),
      ),
    );
  }

  static TextStyle displayStyle(
    BuildContext context, {
    double size = 28,
    FontWeight weight = FontWeight.w700,
    double height = 1.08,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? onSurface,
    );
  }

  static List<BoxShadow> get softShadow => <BoxShadow>[
    BoxShadow(
      color: onSurface.withValues(alpha: 0.07),
      blurRadius: 34,
      offset: const Offset(0, 18),
      spreadRadius: -22,
    ),
  ];

  static List<BoxShadow> get cardShadow => <BoxShadow>[
    BoxShadow(
      color: onSurface.withValues(alpha: 0.05),
      blurRadius: 26,
      offset: const Offset(0, 12),
      spreadRadius: -18,
    ),
  ];
}
