import 'package:flutter/animation.dart';

/// Timings for the way in: Welcome → Sign in → Home. Picked on the "Atura Sign-in Motion" canvas (B + D).

/// A strong ease-out, shared by every custom move on the way in.
const kSignInCurve = Cubic(0.23, 1, 0.32, 1);

/// The sign-in button folding into a check.
const kCheckInFold = Duration(milliseconds: 200);

/// The check holds before the sheet rises.
const kCheckInPause = Duration(milliseconds: 250);

/// The sign-in sheet rising to cover the screen.
const kCheckInRise = Duration(milliseconds: 400);

/// With reduced motion, every step on the way in is a plain cross-fade of this length.
const kReducedMotionFade = Duration(milliseconds: 150);

/// The greeting after the check-in: it fades in, holds (a tap cuts the hold short), then glides into Home's own
/// greeting.
const kGreetingIn = Duration(milliseconds: 300);
const kGreetingHold = Duration(milliseconds: 900);
const kGreetingGlide = Duration(milliseconds: 450);
