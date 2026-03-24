import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color ink = Color(0xFF0F172A);
  static const Color inkSoft = Color(0xFF17233B);
  static const Color slate = Color(0xFF64748B);
  static const Color muted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSoft = Color(0xFFE8EDF5);
  static const Color borderStrong = Color(0xFFD3DCE8);
  static const Color canvas = Color(0xFFF6F4EE);
  static const Color canvasSoft = Color(0xFFF8FAFC);
  static const Color canvasWarm = Color(0xFFFFFCF6);
  static const Color surfaceMuted = Color(0xFFF4F7FB);
  static const Color surface = Colors.white;
  static const Color sapphire = Color(0xFF3153C9);
  static const Color sapphireSoft = Color(0xFFEEF3FF);
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
      scaffoldBackgroundColor: canvasSoft,
      splashFactory: NoSplash.splashFactory,
      hoverColor: surfaceMuted,
      highlightColor: Colors.transparent,
      focusColor: sapphireSoft,
      colorScheme: const ColorScheme.light(
        primary: sapphire,
        secondary: gold,
        surface: surface,
        error: danger,
      ),
      textTheme: textTheme,
      dividerColor: borderSoft,
      cardColor: surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderSoft),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: sapphire, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: danger, width: 1.4),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: slate),
        prefixIconColor: slate,
        suffixIconColor: slate,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return ink.withValues(alpha: 0.36);
            }
            if (states.contains(WidgetState.hovered)) {
              return inkSoft;
            }
            return ink;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(surface),
          elevation: WidgetStateProperty.resolveWith<double>((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.hovered) ? 1.5 : 0;
          }),
          shadowColor: WidgetStateProperty.all<Color>(const Color(0x260F172A)),
          overlayColor: WidgetStateProperty.all<Color>(
            Colors.white.withValues(alpha: 0.04),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(ink),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.hovered)
                ? canvasWarm
                : Colors.white;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.hovered)) {
              return const BorderSide(color: borderStrong);
            }
            return const BorderSide(color: borderSoft);
          }),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(sapphire),
          overlayColor: WidgetStateProperty.all<Color>(
            sapphire.withValues(alpha: 0.06),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ink;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: borderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: ink,
        inactiveTrackColor: borderSoft,
        thumbColor: gold,
        overlayColor: Color(0x220F172A),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: canvasWarm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderSoft),
        ),
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.hovered)
                ? canvasWarm
                : Colors.white;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(ink),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(color: borderSoft),
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
      color: color ?? ink,
    );
  }

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x180F172A),
      blurRadius: 48,
      offset: Offset(0, 26),
      spreadRadius: -30,
    ),
    BoxShadow(
      color: Color(0x0A3153C9),
      blurRadius: 30,
      offset: Offset(0, 10),
      spreadRadius: -24,
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 22,
      offset: Offset(0, 14),
      spreadRadius: -16,
    ),
  ];
}
