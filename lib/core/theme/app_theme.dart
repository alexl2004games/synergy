import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class AppTheme {
  static const Color _lightSeed = Color(0xFF4F78C4);
  static const Color _darkSeed = Color(0xFF7A96DB);
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightSeed,
      surface: const Color(0xFFF6F8FC),
      surfaceContainerHighest: const Color(0xFFE8EDF7),
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _darkSeed,
      brightness: Brightness.dark,
      surface: const Color(0xFF11151E),
      surfaceContainerHighest: const Color(0xFF1A202D),
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }
}
