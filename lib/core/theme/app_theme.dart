import 'package:material_ui/material_ui.dart';

class AppTheme {
  static const Color background = Color(0xFF0B1326);
  static const Color surface = Color(0xFF131B2E);
  static const Color card = Color(0xFF171F33);
  static const Color cardHigh = Color(0xFF222A3D);
  static const Color primary = Color(0xFF8183FF);
  static const Color primarySoft = Color(0xFFC0C1FF);
  static const Color secondary = Color(0xFF0566D9);
  static const Color success = Color(0xFF00885D);
  static const Color text = Color(0xFFDAE2FD);
  static const Color muted = Color(0xFFC7C4D7);
  static const Color outline = Color(0xFF464554);
  static const Color danger = Color(0xFFB3263A);

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: background,
        ).copyWith(
          primary: primary,
          onPrimary: const Color(0xFF0D0096),
          primaryContainer: primary,
          onPrimaryContainer: const Color(0xFF0D0096),
          secondary: secondary,
          onSecondary: text,
          tertiary: success,
          onTertiary: Colors.white,
          surface: background,
          onSurface: text,
          onSurfaceVariant: muted,
          error: const Color(0xFFFFB4AB),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.72)),
        prefixIconColor: muted,
        suffixIconColor: muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF0D0096),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary,
        height: 78,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF0D0096)
                : muted,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(color: outline, thickness: 0.7),
    );
  }
}
