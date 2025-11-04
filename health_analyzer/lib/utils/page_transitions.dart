import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'display_utils.dart';

/// Collection of smooth page transitions for the app
///
/// Uses the animations package to provide:
/// - SharedAxisTransition: For hierarchical navigation (parent→child or lateral movement)
/// - FadeThroughTransition: For replacing content at the same hierarchy level
/// - FadeScaleTransition: For dialog and modal presentations
///
/// Automatically adapts animation duration for high refresh rate displays (90Hz, 120Hz)
class PageTransitions {
  /// Shared axis transition for vertical navigation (e.g., list → detail)
  ///
  /// Use when navigating to a child screen in the hierarchy
  static Route<T> sharedAxisVertical<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      transitionDuration: DisplayUtils.getOptimalAnimationDuration(),
    );
  }

  /// Shared axis transition for horizontal navigation (e.g., tab switching, wizard steps)
  ///
  /// Use for lateral movement at the same hierarchy level
  static Route<T> sharedAxisHorizontal<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      transitionDuration: DisplayUtils.getOptimalAnimationDuration(),
    );
  }

  /// Shared axis transition for scaled navigation (e.g., opening overlays)
  ///
  /// Use for opening auxiliary content like settings or help
  static Route<T> sharedAxisScaled<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      transitionDuration: DisplayUtils.getOptimalAnimationDuration(),
    );
  }

  /// Fade through transition for replacing content
  ///
  /// Best for switching between unrelated content at the same level
  /// e.g., switching between tabs, replacing a whole screen
  static Route<T> fadeThrough<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: DisplayUtils.getOptimalAnimationDuration(),
    );
  }

  /// Fade scale transition for dialogs and modals
  ///
  /// Use for presenting dialogs, bottom sheets, or modal content
  static Route<T> fadeScale<T>({
    required Widget page,
    RouteSettings? settings,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      opaque: false,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      transitionDuration: DisplayUtils.getOptimalAnimationDuration(),
    );
  }

  /// Custom OpenContainer widget wrapper for container transform animations
  ///
  /// Use this for hero-like transitions from a card/tile to a detail screen
  static Widget openContainer({
    required Widget closedChild,
    required Widget Function(BuildContext) openBuilder,
    required VoidCallback onClosed,
    Color? closedColor,
    Color? openColor,
    double closedElevation = 0,
    double openElevation = 0,
    ShapeBorder? closedShape,
    ShapeBorder? openShape,
  }) {
    return OpenContainer(
      closedBuilder: (context, action) => closedChild,
      openBuilder: (context, action) => openBuilder(context),
      onClosed: (data) => onClosed(),
      closedColor: closedColor ?? Colors.transparent,
      openColor: openColor ?? Colors.transparent,
      closedElevation: closedElevation,
      openElevation: openElevation,
      closedShape: closedShape ?? const RoundedRectangleBorder(),
      openShape: openShape ?? const RoundedRectangleBorder(),
      transitionDuration: DisplayUtils.getOptimalAnimationDuration(),
    );
  }

  /// Helper method to navigate with shared axis vertical transition
  static Future<T?> pushVertical<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      sharedAxisVertical(page: page),
    );
  }

  /// Helper method to navigate with shared axis horizontal transition
  static Future<T?> pushHorizontal<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      sharedAxisHorizontal(page: page),
    );
  }

  /// Helper method to navigate with fade through transition
  static Future<T?> pushFadeThrough<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      fadeThrough(page: page),
    );
  }

  /// Helper method to navigate with fade scale (modal) transition
  static Future<T?> pushModal<T>(
    BuildContext context,
    Widget page, {
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return Navigator.of(context).push<T>(
      fadeScale(
        page: page,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
      ),
    );
  }

  /// Helper method to replace current route with shared axis vertical transition
  static Future<T?> replaceVertical<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushReplacement<T, void>(
      sharedAxisVertical(page: page),
    );
  }

  /// Helper method to replace current route with fade through transition
  static Future<T?> replaceFadeThrough<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushReplacement<T, void>(
      fadeThrough(page: page),
    );
  }
}

/// Extension on BuildContext for easier access to page transitions
extension PageTransitionsX on BuildContext {
  /// Navigate to a screen using vertical shared axis transition (hierarchical)
  Future<T?> pushVertical<T>(Widget page) =>
      PageTransitions.pushVertical<T>(this, page);

  /// Navigate to a screen using horizontal shared axis transition (lateral)
  Future<T?> pushHorizontal<T>(Widget page) =>
      PageTransitions.pushHorizontal<T>(this, page);

  /// Navigate to a screen using fade through transition (replacement)
  Future<T?> pushFadeThrough<T>(Widget page) =>
      PageTransitions.pushFadeThrough<T>(this, page);

  /// Navigate to a modal screen using fade scale transition
  Future<T?> pushModal<T>(
    Widget page, {
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) =>
      PageTransitions.pushModal<T>(
        this,
        page,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
      );

  /// Replace current screen using vertical shared axis transition
  Future<T?> replaceVertical<T>(Widget page) =>
      PageTransitions.replaceVertical<T>(this, page);

  /// Replace current screen using fade through transition
  Future<T?> replaceFadeThrough<T>(Widget page) =>
      PageTransitions.replaceFadeThrough<T>(this, page);
}
