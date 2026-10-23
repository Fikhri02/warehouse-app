import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/motion/sign_in_motion.dart';

/// What Welcome and Sign in must agree on: the welcome handoff ends on exactly the frame Sign in starts from.

/// Sign in's background, the colour the welcome band floods into.
const kSignInGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF003439), Color(0xFF00504A)],
);

/// Where Sign in's wordmark sits: from the left edge, and from the top of the safe area.
const kSignInWordmarkInset = Offset(24, 20);
const kSignInWordmarkHeight = 22.0;

/// Sign in building itself in after the handoff, and leaving on back.
const kSignInEntrance = Duration(milliseconds: 450);
const kSignInExit = Duration(milliseconds: 300);

/// The `/login` page. The page itself does not move: LoginScreen animates its own parts from the route animation, so
/// its background and wordmark stay where the welcome handoff left them. With reduced motion it cross-fades.
CustomTransitionPage<void> signInPage(BuildContext context, GoRouterState state, Widget child) {
  final reduced = MediaQuery.disableAnimationsOf(context);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: reduced ? kReducedMotionFade : kSignInEntrance,
    reverseTransitionDuration: reduced ? kReducedMotionFade : kSignInExit,
    child: child,
    transitionsBuilder: (context, animation, _, child) =>
        reduced ? FadeTransition(opacity: animation, child: child) : child,
  );
}
