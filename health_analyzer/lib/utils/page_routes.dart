import 'package:flutter/material.dart';

/// Custom page route with smooth slide and fade transition
class SmoothPageRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final Curve curve;

  SmoothPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide from right with fade
            const begin = Offset(0.05, 0.0);
            const end = Offset.zero;
            final slideTween = Tween(begin: begin, end: end);
            final slideAnimation = animation.drive(
              slideTween.chain(CurveTween(curve: curve)),
            );

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            final fadeAnimation = animation.drive(
              fadeTween.chain(CurveTween(curve: curve)),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Custom page route with scale and fade transition
class ScalePageRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final Curve curve;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween<double>(begin: 0.92, end: 1.0);
            final scaleAnimation = animation.drive(
              scaleTween.chain(CurveTween(curve: curve)),
            );

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            final fadeAnimation = animation.drive(
              fadeTween.chain(CurveTween(curve: curve)),
            );

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Shared axis transition (Material Design standard)
class SharedAxisPageRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final SharedAxisTransitionType transitionType;

  SharedAxisPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.transitionType = SharedAxisTransitionType.scaled,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              animation,
              secondaryAnimation,
              child,
              transitionType,
            );
          },
        );

  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    SharedAxisTransitionType type,
  ) {
    switch (type) {
      case SharedAxisTransitionType.scaled:
        return _scaledTransition(animation, secondaryAnimation, child);
      case SharedAxisTransitionType.horizontal:
        return _horizontalTransition(animation, secondaryAnimation, child);
      case SharedAxisTransitionType.vertical:
        return _verticalTransition(animation, secondaryAnimation, child);
    }
  }

  static Widget _scaledTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }

  static Widget _horizontalTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget _verticalTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

enum SharedAxisTransitionType {
  scaled,
  horizontal,
  vertical,
}
