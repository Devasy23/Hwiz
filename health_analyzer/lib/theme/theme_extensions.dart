import 'package:flutter/material.dart';

/// Extension methods for easy access to Material 3 theme colors
/// Provides convenient getters for color scheme properties
extension ThemeExtensions on BuildContext {
  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Primary colors
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;

  // Secondary colors
  Color get secondaryColor => colorScheme.secondary;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get secondaryContainer => colorScheme.secondaryContainer;
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;

  // Tertiary colors
  Color get tertiaryColor => colorScheme.tertiary;
  Color get onTertiaryColor => colorScheme.onTertiary;
  Color get tertiaryContainer => colorScheme.tertiaryContainer;
  Color get onTertiaryContainer => colorScheme.onTertiaryContainer;

  // Surface colors
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get surfaceVariant => colorScheme.surfaceContainerHighest;
  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;

  // Background (deprecated in Material 3, use surface instead)
  Color get backgroundColor => colorScheme.surface;

  // Error colors
  Color get errorColor => colorScheme.error;
  Color get onErrorColor => colorScheme.onError;

  // Outline
  Color get outlineColor => colorScheme.outline;
  Color get outlineVariantColor => colorScheme.outlineVariant;

  // Additional surface containers
  Color get surfaceContainerLowest => colorScheme.surfaceContainerLowest;
  Color get surfaceContainerLow => colorScheme.surfaceContainerLow;
  Color get surfaceContainer => colorScheme.surfaceContainer;
  Color get surfaceContainerHigh => colorScheme.surfaceContainerHigh;
  Color get surfaceContainerHighest => colorScheme.surfaceContainerHighest;

  // Inverse colors for elevated surfaces
  Color get inverseSurface => colorScheme.inverseSurface;
  Color get onInverseSurface => colorScheme.onInverseSurface;
  Color get inversePrimary => colorScheme.inversePrimary;

  // Check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Get appropriate color based on theme mode
  Color dynamicColor({required Color light, required Color dark}) {
    return isDarkMode ? dark : light;
  }
}

/// Extension for semantic color states
extension ColorStateExtension on BuildContext {
  /// Get color for success state (green)
  Color get successColor =>
      isDarkMode ? const Color(0xFF34D399) : const Color(0xFF10B981);

  /// Get color for warning state (orange)
  Color get warningColor =>
      isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);

  /// Get color for info state (blue)
  Color get infoColor =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);

  /// Get container color for success state
  Color get successContainer =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);

  /// Get container color for warning state
  Color get warningContainer =>
      isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);

  /// Get container color for info state
  Color get infoContainer =>
      isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
}

/// Extension for elevation-based tonal surfaces
extension ElevationExtension on BuildContext {
  /// Get surface color at specific elevation level (0-5)
  /// Material 3 uses tonal surfaces instead of shadows for elevation
  Color surfaceAtElevation(int level) {
    switch (level) {
      case 0:
        return colorScheme.surface;
      case 1:
        return colorScheme.surfaceContainerLowest;
      case 2:
        return colorScheme.surfaceContainerLow;
      case 3:
        return colorScheme.surfaceContainer;
      case 4:
        return colorScheme.surfaceContainerHigh;
      case 5:
        return colorScheme.surfaceContainerHighest;
      default:
        return colorScheme.surface;
    }
  }
}
