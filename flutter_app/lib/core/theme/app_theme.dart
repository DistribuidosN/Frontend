import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color ink = Color(0xFF0F172A);
  static const Color slate = Color(0xFF64748B);
  static const Color muted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color canvas = Color(0xFFF6F4EE);
  static const Color canvasSoft = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color gold = Color(0xFFFACC15);
  static const Color goldDeep = Color(0xFFEAB308);
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFF0FDF4);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoSoft = Color(0xFFEFF6FF);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF7ED);
  static const Color midnight = Color(0xFF111827);

  static ThemeData lightTheme() {
    final textTheme = GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.04,
        color: ink,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.06,
        color: ink,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.08,
        color: ink,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.08,
        color: ink,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: ink,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: ink,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.55,
        color: ink,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.55,
        color: ink,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: slate,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: ink,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: ink,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: slate,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: ink,
        secondary: gold,
        surface: surface,
        error: danger,
      ),
      textTheme: textTheme,
      dividerColor: border,
      cardColor: surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: canvasSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: surface,
          elevation: 0,
          shadowColor: const Color(0x240F172A),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ink;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: ink,
        inactiveTrackColor: border,
        thumbColor: gold,
        overlayColor: Color(0x220F172A),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      color: color ?? ink,
    );
  }

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 40,
      offset: Offset(0, 24),
      spreadRadius: -28,
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x100F172A),
      blurRadius: 18,
      offset: Offset(0, 12),
      spreadRadius: -14,
    ),
  ];
}
