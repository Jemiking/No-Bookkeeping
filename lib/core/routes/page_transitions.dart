import 'package:flutter/material.dart';

/// Custom page transitions for the application
class PageTransitions {
  /// Fade transition
  static Page<dynamic> fadeTransition({
    required Widget child,
    required String key,
  }) {
    return CustomTransitionPage<dynamic>(
      key: ValueKey(key),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Slide transition from right
  static Page<dynamic> slideRightTransition({
    required Widget child,
    required String key,
  }) {
    return CustomTransitionPage<dynamic>(
      key: ValueKey(key),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Slide transition from bottom
  static Page<dynamic> slideUpTransition({
    required Widget child,
    required String key,
  }) {
    return CustomTransitionPage<dynamic>(
      key: ValueKey(key),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Scale transition
  static Page<dynamic> scaleTransition({
    required Widget child,
    required String key,
  }) {
    return CustomTransitionPage<dynamic>(
      key: ValueKey(key),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }

  /// Fade and scale transition combined
  static Page<dynamic> fadeScaleTransition({
    required Widget child,
    required String key,
  }) {
    return CustomTransitionPage<dynamic>(
      key: ValueKey(key),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  /// Rotation and scale transition combined
  static Page<dynamic> rotationScaleTransition({
    required Widget child,
    required String key,
  }) {
    return CustomTransitionPage<dynamic>(
      key: ValueKey(key),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return RotationTransition(
          turns: animation.drive(Tween(begin: 0.5, end: 1.0)),
          child: ScaleTransition(
            scale: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
} 