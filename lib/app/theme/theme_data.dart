import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  const primaryGreen = Color(0xFF2E7D32);
  const lightSurface = Colors.white;

  final lightColorScheme = const ColorScheme.light(
    primary: primaryGreen,
    secondary: Color(0xFF4CAF50),
    surface: lightSurface,
    onSurface: Color(0xFF162028),
    onPrimary: Colors.white,
    error: Color(0xFFB3261E),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: const Color(0xFFF3F5F7),
    fontFamily: 'OpenSans Regular',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF3F5F7),
      foregroundColor: Color(0xFF162028),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardColor: lightSurface,
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black.withValues(alpha: 0.88),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFF162028),
      textColor: Color(0xFF162028),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF667085)),
      labelStyle: const TextStyle(color: Color(0xFF475467)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD92D20)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1.3),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF175A2A),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2E7D32),
      unselectedItemColor: Color(0xFF79808A),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
      showUnselectedLabels: true,
    ),
  );
}

ThemeData getApplicationDarkTheme() {
  const darkPrimary = Color(0xFF81C784);
  const darkSurface = Color(0xFF1A1F1D);
  const darkBackground = Color(0xFF0F1412);

  final darkColorScheme = const ColorScheme.dark(
    primary: darkPrimary,
    secondary: Color(0xFF66BB6A),
    surface: darkSurface,
    onSurface: Color(0xFFE8ECE9),
    onPrimary: Color(0xFF0F1412),
    error: Color(0xFFF2B8B5),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'OpenSans Regular',
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Color(0xFFE8ECE9),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: darkSurface,
    dialogTheme: const DialogThemeData(backgroundColor: darkSurface),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurface,
      modalBackgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      contentTextStyle: const TextStyle(color: Color(0xFFE8ECE9)),
      actionTextColor: darkPrimary,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFFE8ECE9),
      textColor: Color(0xFFE8ECE9),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF242A27),
      hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
      labelStyle: const TextStyle(color: Color(0xFFB7C0BA)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A4440)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A4440)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimary, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF2B8B5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF2B8B5), width: 1.3),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: const Color(0xFF0F1412),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: const Color(0xFF0F1412),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimary,
      ),
    ),
    dividerColor: Colors.white12,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1F1D),
      selectedItemColor: Color(0xFF81C784),
      unselectedItemColor: Color(0xFF95A29A),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
      showUnselectedLabels: true,
    ),
  );
}
