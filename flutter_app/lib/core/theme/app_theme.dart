import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color white = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFF003049);
  static const Color red = Color(0xFFD62828);
  static const Color orange = Color(0xFFF77F00);
  static const Color gold = Color(0xFFFCBF49);
  static const Color sand = Color(0xFFEAE2B7);
  static const Color statusGreen = Color(0xFF2E7D32);

  static const Color ink = navy;
  static const Color inkSoft = navy;
  static const Color slate = navy;
  static const Color muted = Color(0x80003049);
  static const Color border = Color(0x22003049);
  static const Color borderSoft = Color(0x16003049);
  static const Color borderStrong = Color(0x30003049);
  static const Color canvas = white;
  static const Color canvasSoft = sand;
  static const Color canvasWarm = sand;
  static const Color surfaceMuted = sand;
  static const Color surface = white;
  static const Color sapphire = navy;
  static const Color sapphireSoft = sand;
  static const Color goldDeep = orange;
  static const Color success = orange;
  static const Color successSoft = sand;
  static const Color info = gold;
  static const Color infoSoft = sand;
  static const Color danger = red;
  static const Color dangerSoft = sand;
  static const Color warning = gold;
  static const Color warningSoft = sand;
  static const Color midnight = navy;

  static ThemeData lightTheme() {
    final TextTheme textTheme = GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.02,
        color: navy,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.04,
        color: navy,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.06,
        color: navy,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.06,
        color: navy,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.08,
        color: navy,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: navy,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: navy,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: navy,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: navy,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.58,
        color: navy,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.58,
        color: navy,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.52,
        color: navy,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.1,
        color: navy,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        color: navy,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: orange,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      splashFactory: NoSplash.splashFactory,
      hoverColor: gold.withValues(alpha: 0.08),
      highlightColor: white,
      focusColor: orange.withValues(alpha: 0.12),
      colorScheme: const ColorScheme.light(
        primary: red,
        secondary: orange,
        surface: white,
        error: red,
        onPrimary: white,
        onSecondary: navy,
        onSurface: navy,
        onError: white,
      ),
      textTheme: textTheme,
      dividerColor: border,
      cardColor: white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sand.withValues(alpha: 0.38),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderStrong, width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderStrong, width: 1.1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: navy.withValues(alpha: 0.14),
            width: 1.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: orange, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: navy.withValues(alpha: 0.58),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: navy.withValues(alpha: 0.88),
        ),
        prefixIconColor: navy,
        suffixIconColor: navy,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return red.withValues(alpha: 0.56);
            }
            if (states.contains(WidgetState.pressed)) {
              return orange;
            }
            if (states.contains(WidgetState.hovered)) {
              return red;
            }
            return red;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            return sand;
          }),
          overlayColor: WidgetStateProperty.all<Color>(
            navy.withValues(alpha: 0.08),
          ),
          elevation: WidgetStateProperty.resolveWith<double>((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.hovered) ? 2 : 0;
          }),
          shadowColor: WidgetStateProperty.all<Color>(
            navy.withValues(alpha: 0.24),
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
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            return navy;
          }),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return gold.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered)) {
              return sand.withValues(alpha: 0.52);
            }
            return white;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            return BorderSide(
              color: states.contains(WidgetState.hovered)
                  ? gold.withValues(alpha: 0.7)
                  : border,
              width: 1.1,
            );
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
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.hovered) ? red : navy;
          }),
          overlayColor: WidgetStateProperty.all<Color>(
            gold.withValues(alpha: 0.1),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return red;
          }
          return sand;
        }),
        checkColor: WidgetStateProperty.all<Color>(sand),
        side: const BorderSide(color: gold, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: orange,
        inactiveTrackColor: gold.withValues(alpha: 0.22),
        thumbColor: red,
        overlayColor: red.withValues(alpha: 0.12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sand,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: gold, width: 1.1),
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
            if (states.contains(WidgetState.hovered)) {
              return sand.withValues(alpha: 0.52);
            }
            return white;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            return navy;
          }),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(color: gold, width: 1.1),
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
      color: color ?? navy,
    );
  }

  static List<BoxShadow> get softShadow => <BoxShadow>[
    BoxShadow(
      color: navy.withValues(alpha: 0.08),
      blurRadius: 34,
      offset: const Offset(0, 18),
      spreadRadius: -22,
    ),
  ];

  static List<BoxShadow> get cardShadow => <BoxShadow>[
    BoxShadow(
      color: navy.withValues(alpha: 0.07),
      blurRadius: 22,
      offset: const Offset(0, 14),
      spreadRadius: -18,
    ),
  ];
}
