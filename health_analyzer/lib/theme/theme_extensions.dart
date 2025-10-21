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
}
