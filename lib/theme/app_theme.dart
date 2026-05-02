import 'package:flutter/material.dart';

class AppTheme {
  // 🖤✨ Palette Luxury Dark Gold
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF5E27A);
  static const Color goldDark = Color(0xFF9A7B1C);
  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color bgCard = Color(0xFF141414);
  static const Color bgSurface = Color(0xFF1C1C1C);
  static const Color textWhite = Color(0xFFF5F5F5);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFF2A2A2A);

  // ✅ Aliases — compatibilité anciens fichiers
  static const Color primary = gold;
  static const Color secondary = goldLight;
  static const Color accent = gold;
  static const Color background = bgDark;
  static const Color textDark = textWhite;
  static const Color cardBg = bgCard;

  // 🌟 Dégradés
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E27A), Color(0xFF9A7B1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGoldGradient = LinearGradient(
    colors: [Color(0xFF1C1C1C), Color(0xFF2A2310)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF1A1500), Color(0xFF0A0A0A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: goldLight,
      surface: bgSurface,
    ),
    fontFamily: 'Roboto',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: bgDark,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        shadowColor: Color.fromRGBO(212, 175, 55, 0.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Color.fromRGBO(212, 175, 55, 0.25), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      foregroundColor: gold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: gold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgSurface,
      labelStyle: const TextStyle(color: textLight),
      prefixIconColor: gold,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Color.fromRGBO(212, 175, 55, 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Color.fromRGBO(212, 175, 55, 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
    ),
  );
}

extension AppThemeColorHelpers on Color {
  Color withOpacityValue(double opacity) => withAlpha((opacity * 255).round());
}
