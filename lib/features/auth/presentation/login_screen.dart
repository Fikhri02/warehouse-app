import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/biometrics.dart';
import 'package:warehouse_app/core/motion/arrival.dart';
import 'package:warehouse_app/core/motion/sign_in_motion.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/atura_logo.dart';
import 'package:warehouse_app/features/auth/presentation/sign_in_geometry.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';

/// How far the right side of the form's top edge sits below its left; the hero art rests in that dip.
const double _sheetDip = 40;
const double _artHeight = 210;

/// Where the art's bottom rests, measured down from the form's highest edge; the form covers what falls below it.
const double _artRest = 20;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  /// The check the sign-in button folds into once the person is in.
  static const checkInKey = ValueKey('check-in');

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _showPassword = false;
  bool _keyboardWasOpen = false;

  /// Set on the first tap of Sign in (or a fingerprint), so a second tap never signs in twice.
  bool _submitting = false;

  /// Whether the sheet was raised (a field focused) and the fingerprint offered when the sign-in started: both stay as
  /// they were through the check-in, so dropping the keyboard or using up the locked session does not shift the form.
  bool _raisedAtSubmit = false;
  bool _fingerprintAtSubmit = false;
  late final StateController<bool> _hold;
  late final StateController<bool> _arrival;
  late final AnimationController _checkIn =
      AnimationController(vsync: this, duration: kCheckInFold + kCheckInPause + kCheckInRise);
  static final _foldEnd = kCheckInFold.inMilliseconds / (kCheckInFold + kCheckInPause + kCheckInRise).inMilliseconds;
  static final _riseStart =
      (kCheckInFold + kCheckInPause).inMilliseconds / (kCheckInFold + kCheckInPause + kCheckInRise).inMilliseconds;

  /// Typing into either field raises the form to fill the screen.
  bool get _formRaised => _emailFocus.hasFocus || _passwordFocus.hasFocus;

  @override
  void initState() {
    super.initState();
    _hold = ref.read(entryHeldProvider.notifier);
    _arrival = ref.read(arrivalPendingProvider.notifier);
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);
    // Biometric login is on and a session is stored: ask straight away.
    if (ref.read(lockedSessionProvider) != null) Future.microtask(_biometricSignIn);
  }

  @override
  void dispose() {
    // Never leave the router waiting on a screen that is gone.
    if (_hold.state) Future.microtask(() => _hold.state = false);
    _checkIn.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  /// Locks the form for one sign-in: drops the keyboard, keeps the sheet and fingerprint button where they are.
  void _startSubmitting() {
    _submitting = true;
    _raisedAtSubmit = _formRaised;
    _fingerprintAtSubmit = ref.read(lockedSessionProvider) != null;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// The keyboard closed without a tap outside (Android back): lower the form with it.
  @override
  void didChangeMetrics() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return;
    final open = views.first.viewInsets.bottom > 0;
    if (_keyboardWasOpen && !open && _formRaised) FocusManager.instance.primaryFocus?.unfocus();
    _keyboardWasOpen = open;
  }

  Future<void> _signIn() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    _startSubmitting();
    final animate = !MediaQuery.disableAnimationsOf(context);
    if (animate) _hold.state = true;
    await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (!mounted) return;
    if (!animate || ref.read(authNotifierProvider).hasError) {
      _hold.state = false;
      _submitting = false;
      return;
    }
    await _playCheckIn();
  }

  Future<void> _biometricSignIn() async {
    if (_submitting || ref.read(lockedSessionProvider) == null) return;
    _startSubmitting();
    final animate = !MediaQuery.disableAnimationsOf(context);
    if (!await ref.read(biometricAuthProvider).authenticate('Unlock Atura') || !mounted) {
      _submitting = false;
      return;
    }
    if (animate) _hold.state = true;
    ref.read(authNotifierProvider.notifier).unlock();
    if (animate) await _playCheckIn();
  }

  /// The button folds into a check, holds, then the sheet rises to cover the screen; only then may the router leave.
  Future<void> _playCheckIn() async {
    await _checkIn.animateTo(_foldEnd);
    if (!mounted) return;
    if (ref.read(profileSettingsProvider).hapticFeedbackEnabled) HapticFeedback.mediumImpact();
    await _checkIn.forward();
    if (!mounted) return;
    if (ref.read(authNotifierProvider).valueOrNull == null) {
      // The session went away mid check-in (it expired, or there was nothing to unlock): back to a usable form.
      _checkIn.value = 0;
      setState(() => _submitting = false);
    } else {
      _arrival.state = true; // Home arrives in steps, this once
    }
    _hold.state = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topInset = MediaQuery.paddingOf(context).top;
    final accent = brightness == Brightness.dark ? AppColors.darkAccent : AppColors.primary;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.hasError ? (authState.error?.toString() ?? 'Login failed. Please try again.') : null;
    // Only offered once biometric login is on and there is a session to unlock.
    final canUseFingerprint = ref.watch(lockedSessionProvider) != null || (_submitting && _fingerprintAtSubmit);
    // Building in after the welcome handoff (and out again on back). The background and wordmark never move. With
    // reduced motion the page cross-fades and nothing inside it moves.
    final entrance = MediaQuery.disableAnimationsOf(context)
        ? kAlwaysCompleteAnimation
        : ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          // A tap outside the fields closes the keyboard and lowers the form.
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: kSignInGradient),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // At rest the form takes the bottom 60% and nothing scrolls. Raised, it fills the screen from just
                // under the status bar down to the keyboard; only then can its contents scroll.
                final raisedHeight = constraints.maxHeight - topInset - 8;
                final restHeight = screenHeight * 0.6;
                return Stack(
                  children: [
                    // Behind everything: the headline and the form both sit in front of it.
                    Positioned(
                      right: -12, // runs off the right edge
                      top: screenHeight * 0.4 + _artRest - _artHeight,
                      height: _artHeight,
                      child: AnimatedBuilder(
                        animation: entrance,
                        builder: (context, child) {
                          final t = const Interval(0.3, 1, curve: kSignInCurve).transform(entrance.value);
                          return Opacity(
                            opacity: t,
                            child: Transform.translate(offset: Offset(16 * (1 - t), 0), child: child),
                          );
                        },
                        child: const ExcludeSemantics(
                          child: Image(
                            image: AssetImage('assets/branding/login_hero_art.png'),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                    Positioned(top: 0, left: 0, right: 0, height: screenHeight * 0.4, child: _Hero(entrance: entrance)),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedBuilder(
                        animation: entrance,
                        builder: (context, child) => FractionalTranslation(
                          translation: Offset(0, 1 - kSignInCurve.transform(entrance.value)),
                          child: child,
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: _formRaised || (_submitting && _raisedAtSubmit) ? 1 : 0),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 200),
                          curve: const Cubic(0.23, 1, 0.32, 1),
                          builder: (context, t, child) => AnimatedBuilder(
                            animation: _checkIn,
                            builder: (context, child) {
                              final typed = (restHeight + (raisedHeight - restHeight) * t).clamp(0.0, raisedHeight);
                              // The check-in rise: up past the top by the dip, so the whole screen is the sheet's ground.
                              final rise = Interval(_riseStart, 1, curve: kSignInCurve).transform(_checkIn.value);
                              final height = lerpDouble(typed, constraints.maxHeight + _sheetDip, rise)!;
                              return ConstrainedBox(
                                constraints:
                                    BoxConstraints(minHeight: height, maxHeight: math.max(raisedHeight, height)),
                                child: child,
                              );
                            },
                            child: child,
                          ),
                          child: ClipPath(
                            clipper: _SheetClipper(),
                            child: ColoredBox(
                              color: theme.scaffoldBackgroundColor,
                              child: AnimatedBuilder(
                                animation: _checkIn,
                                // The form's contents leave over the first half of the rise.
                                builder: (context, child) => Opacity(
                                  opacity: 1 -
                                      Interval(_riseStart, (1 + _riseStart) / 2, curve: kSignInCurve)
                                          .transform(_checkIn.value),
                                  child: child,
                                ),
                                child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  child: SafeArea(
                                    top: false,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                                      child: Form(
                                        key: _formKey,
                                        child: AutofillGroup(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Text('Sign in',
                                                  style: AppTextStyles.display.copyWith(
                                                      color: AppColors.textPrimary(brightness),
                                                      fontSize: 26,
                                                      height: 1.2)),
                                              Text('Use your warehouse account',
                                                  style: AppTextStyles.body.copyWith(
                                                      color: AppColors.textSecondary(brightness), height: 1.3)),
                                              const SizedBox(height: 20),
                                              const _FieldLabel('Email'),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: _emailController,
                                                focusNode: _emailFocus,
                                                keyboardType: TextInputType.emailAddress,
                                                textInputAction: TextInputAction.next,
                                                autofillHints: const [AutofillHints.email],
                                                autocorrect: false,
                                                validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null,
                                              ),
                                              const SizedBox(height: 12),
                                              const _FieldLabel('Password'),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: _passwordController,
                                                focusNode: _passwordFocus,
                                                obscureText: !_showPassword,
                                                textInputAction: TextInputAction.done,
                                                autofillHints: const [AutofillHints.password],
                                                onFieldSubmitted: (_) => isLoading ? null : _signIn(),
                                                decoration: InputDecoration(
                                                  suffixIcon: IconButton(
                                                    tooltip: _showPassword ? 'Hide password' : 'Show password',
                                                    icon: Icon(_showPassword
                                                        ? Icons.visibility_off_outlined
                                                        : Icons.visibility_outlined),
                                                    color: AppColors.textSecondary(brightness),
                                                    onPressed: () => setState(() => _showPassword = !_showPassword),
                                                  ),
                                                ),
                                                validator: (v) =>
                                                    (v == null || v.isEmpty) ? 'Enter your password' : null,
                                              ),
                                              const SizedBox(height: 20),
                                              if (errorMessage != null) ...[
                                                Text(errorMessage,
                                                    style: AppTextStyles.body.copyWith(color: AppColors.error)),
                                                const SizedBox(height: 8),
                                              ],
                                              // Folds into a 48pt circle with a check once the person is in. It stays
                                              // enabled while signing in; _signIn ignores every tap after the first.
                                              AnimatedBuilder(
                                                animation: _checkIn,
                                                builder: (context, _) {
                                                  final fold = Interval(0, _foldEnd, curve: kSignInCurve)
                                                      .transform(_checkIn.value);
                                                  return LayoutBuilder(
                                                    builder: (context, box) => Align(
                                                      child: SizedBox(
                                                        width: lerpDouble(box.maxWidth, 48, fold),
                                                        height: 48,
                                                        child: ElevatedButton(
                                                          onPressed: _signIn,
                                                          style: ElevatedButton.styleFrom(
                                                            minimumSize: const Size(48, 48),
                                                            padding: EdgeInsets.zero,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(lerpDouble(8, 24, fold)!)),
                                                          ),
                                                          child: _checkIn.value > 0
                                                              ? Opacity(
                                                                  opacity: fold,
                                                                  child: Icon(Icons.check_rounded,
                                                                      key: LoginScreen.checkInKey,
                                                                      color: theme.colorScheme.onPrimary),
                                                                )
                                                              : isLoading
                                                                  ? SizedBox(
                                                                      height: 18,
                                                                      width: 18,
                                                                      child: CircularProgressIndicator(
                                                                          strokeWidth: 2,
                                                                          color: theme.colorScheme.onPrimary),
                                                                    )
                                                                  : const Text('Sign in'),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              if (canUseFingerprint) ...[
                                                const SizedBox(height: 12),
                                                OutlinedButton.icon(
                                                  onPressed: isLoading ? null : _biometricSignIn,
                                                  style: OutlinedButton.styleFrom(
                                                    minimumSize: const Size(double.infinity, 48),
                                                    foregroundColor: accent,
                                                    side: BorderSide(color: accent),
                                                    shape:
                                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  icon: const Icon(Icons.fingerprint),
                                                  label: const Text('Use fingerprint'),
                                                ),
                                              ],
                                              const SizedBox(height: 20),
                                              Text(
                                                'Need access? Contact your supervisor.',
                                                textAlign: TextAlign.center,
                                                style: AppTextStyles.body
                                                    .copyWith(color: AppColors.textSecondary(brightness), height: 1.3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Wordmark and the one big line, on the page's brand gradient. The wordmark is where the welcome handoff leaves it;
/// the line and tagline fade up as Sign in builds in.
class _Hero extends StatelessWidget {
  final Animation<double> entrance;
  const _Hero({required this.entrance});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(kSignInWordmarkInset.dx, kSignInWordmarkInset.dy, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AturaWordmark(height: kSignInWordmarkHeight, color: Colors.white),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: entrance,
              builder: (context, child) {
                final t = const Interval(0.1, 0.8, curve: kSignInCurve).transform(entrance.value);
                return Opacity(
                  opacity: t,
                  child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width * 0.62),
                    child: Text(
                      'Ready for\nthe next shift.',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Stock. Scan. Move.', style: AppTextStyles.body.copyWith(color: Colors.white70, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded top corners, the left side higher than the right, joined by an S-curve the art settles into.
class _SheetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 24.0;
    final w = size.width;
    return Path()
      ..moveTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(w * 0.42, 0)
      ..cubicTo(w * 0.56, 0, w * 0.6, _sheetDip, w * 0.74, _sheetDip)
      ..lineTo(w - r, _sheetDip)
      ..quadraticBezierTo(w, _sheetDip, w, _sheetDip + r)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_SheetClipper oldClipper) => false;
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary(Theme.of(context).brightness),
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      );
}
