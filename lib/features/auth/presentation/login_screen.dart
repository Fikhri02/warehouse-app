import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/biometrics.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/atura_logo.dart';

/// How far the right side of the form's top edge sits below its left; the hero art rests in that dip.
const double _sheetDip = 40;
const double _artHeight = 210;

/// Where the art's bottom rests, measured down from the form's highest edge; the form covers what falls below it.
const double _artRest = 20;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    // Biometric login is on and a session is stored: ask straight away.
    if (ref.read(lockedSessionProvider) != null) Future.microtask(_biometricSignIn);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _biometricSignIn() async {
    if (ref.read(lockedSessionProvider) == null) return;
    if (await ref.read(biometricAuthProvider).authenticate('Unlock Atura')) {
      ref.read(authNotifierProvider.notifier).unlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final accent = brightness == Brightness.dark ? AppColors.darkAccent : AppColors.primary;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.hasError ? (authState.error?.toString() ?? 'Login failed. Please try again.') : null;
    // Only offered once biometric login is on and there is a session to unlock.
    final canUseFingerprint = ref.watch(lockedSessionProvider) != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF00504A)],
            ),
          ),
          // Header 40%, form 60%, measured from the screen rather than the body so the header keeps its height when
          // the keyboard opens and the form scrolls instead.
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              children: [
                // Behind everything: the headline and the form both sit in front of it.
                Positioned(
                  right: -12, // runs off the right edge
                  top: screenHeight * 0.4 + _artRest - _artHeight,
                  height: _artHeight,
                  child: const ExcludeSemantics(
                    child: Image(
                      image: AssetImage('assets/branding/login_hero_art.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.4, child: const _Hero()),
                    ClipPath(
                      clipper: _SheetClipper(),
                      child: Container(
                        constraints: BoxConstraints(minHeight: screenHeight * 0.6),
                        color: theme.scaffoldBackgroundColor,
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
                                            color: AppColors.textPrimary(brightness), fontSize: 26, height: 1.2)),
                                    Text('Use your warehouse account',
                                        style: AppTextStyles.body
                                            .copyWith(color: AppColors.textSecondary(brightness), height: 1.3)),
                                    const SizedBox(height: 20),
                                    const _FieldLabel('Email'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailController,
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
                                      validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                                    ),
                                    const SizedBox(height: 20),
                                    if (errorMessage != null) ...[
                                      Text(errorMessage, style: AppTextStyles.body.copyWith(color: AppColors.error)),
                                      const SizedBox(height: 8),
                                    ],
                                    ElevatedButton(
                                      onPressed: isLoading ? null : _signIn,
                                      child: isLoading
                                          ? SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2, color: theme.colorScheme.onPrimary),
                                            )
                                          : const Text('Sign in'),
                                    ),
                                    if (canUseFingerprint) ...[
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                        onPressed: isLoading ? null : _biometricSignIn,
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(double.infinity, 48),
                                          foregroundColor: accent,
                                          side: BorderSide(color: accent),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wordmark and the one big line, on the page's brand gradient.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AturaWordmark(height: 22, color: Colors.white),
            const SizedBox(height: 28),
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
