import 'package:material_ui/material_ui.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color surfaceLight = Color(0xFFF8F9FF);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        surface: surfaceLight,
      ),
      scaffoldBackgroundColor: surfaceLight,
      cardTheme: CardThemeData( // <--- Cambiado de CardTheme a CardThemeData
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}