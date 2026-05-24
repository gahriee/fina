import 'package:flutter/material.dart';

class AppColors {
  static const primary            = Color(0xFFEA580C);
  static const primaryDark        = Color(0xFFFB923C);

  static const background         = Color(0xFFF2F2F7);
  static const backgroundDark     = Color(0xFF000000);
  static const surface            = Color(0xFFFFFFFF);
  static const surfaceDark        = Color(0xFF1C1C1E);
  static const surfaceVariant     = Color(0xFFF2F2F7);
  static const surfaceVariantDark = Color(0xFF2C2C2E);

  static const textPrimary        = Color(0xFF000000);
  static const textPrimaryDark    = Color(0xFFFFFFFF);
  static const textSecondary      = Color(0xFF6C6C70);
  static const textSecondaryDark  = Color(0xFF98989D);

  static const outline            = Color(0xFFC6C6C8);
  static const outlineDark        = Color(0xFF38383A);

  static const income             = Color(0xFF16A34A);
  static const incomeDark         = Color(0xFF4ADE80);
  static const expense            = Color(0xFFDC2626);
  static const expenseDark        = Color(0xFFF87171);
  static const warning            = Color(0xFFD97706);
  static const warningDark        = Color(0xFFFBBF24);
}

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:                 AppColors.primary,
    onPrimary:               Colors.white,
    surface:                 AppColors.surface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    outline:                 AppColors.outline,
    onSurface:               AppColors.textPrimary,
    onSurfaceVariant:        AppColors.textSecondary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
  ),

  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surface,
    selectedItemColor:   AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.outline),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary:                 AppColors.primaryDark,
    onPrimary:               Colors.white,
    surface:                 AppColors.surfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    outline:                 AppColors.outlineDark,
    onSurface:               AppColors.textPrimaryDark,
    onSurfaceVariant:        AppColors.textSecondaryDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
  ),

  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.outlineDark),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariantDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outlineDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surfaceDark,
    selectedItemColor:   AppColors.primaryDark,
    unselectedItemColor: AppColors.textSecondaryDark,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.outlineDark),
);
