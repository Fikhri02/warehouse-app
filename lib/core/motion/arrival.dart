import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/motion/sign_in_motion.dart';

/// Set by Sign in as its check-in ends, so the next Home page arrives in steps; cleared once that arrival is done.
/// Coming back to Home any other way uses the normal page transition.
final arrivalPendingProvider = StateProvider<bool>((_) => false);

/// How long Home takes to arrive after the check-in.
const kArrival = Duration(milliseconds: 450);

/// The gap between one section starting and the next.
const kArrivalStep = Duration(milliseconds: 60);

/// Each section's own fade, inside [kArrival].
const _sectionSpan = Duration(milliseconds: 210);

/// The home shell's arrival, handed down from its page transition so sections inside nested navigators can follow it.
class ArrivalAnimation extends InheritedWidget {
  final Animation<double> animation;
  const ArrivalAnimation({super.key, required this.animation, required super.child});

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArrivalAnimation>()?.animation;

  @override
  bool updateShouldNotify(ArrivalAnimation oldWidget) => oldWidget.animation != animation;
}

/// A section of Home that arrives [order] steps after the first: it fades in and rises 8pt, or with [fromBelow]
/// slides up from its own height (the bottom bar). Outside an arrival it shows as-is.
class StaggeredEntrance extends StatelessWidget {
  final int order;
  final bool fromBelow;
  final Widget child;
  const StaggeredEntrance({super.key, required this.order, this.fromBelow = false, required this.child});

  @override
  Widget build(BuildContext context) {
    final animation = ArrivalAnimation.maybeOf(context);
    if (animation == null) return Opacity(opacity: 1, child: child);
    final start = order * kArrivalStep.inMilliseconds / kArrival.inMilliseconds;
    final end = math.min(1.0, start + _sectionSpan.inMilliseconds / kArrival.inMilliseconds);
    final interval = Interval(start, end, curve: kSignInCurve);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = interval.transform(animation.value);
        return fromBelow
            ? FractionalTranslation(translation: Offset(0, 1 - t), child: Opacity(opacity: 1, child: child))
            : Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child));
      },
      child: child,
    );
  }
}
