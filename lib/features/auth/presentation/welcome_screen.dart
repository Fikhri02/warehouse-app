import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/motion/sign_in_motion.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/widgets/atura_logo.dart';
import 'package:warehouse_app/features/auth/presentation/sign_in_geometry.dart';

/// Start my shift: the badge straightens, the lanyard pulls up, the band floods into Sign in's teal and the wordmark
/// flies to Sign in's header. Back runs it in reverse.
const kBadgeHandoff = Duration(milliseconds: 800);
const _handoffBack = Duration(milliseconds: 560);

/// The first screen a signed-out person sees: a staff badge hanging from a lanyard, with a live clock, the shift by
/// time of day and an empty photo slot waiting for its owner, then one way in. Staff share devices and sign in at the
/// start of every shift.
///
/// Built to the handoff spec of the light "Morning shift" concept (reference viewport 393 × 852): Plus Jakarta Sans,
/// a 248 × 378 badge tilted −4.2° under a woven lanyard, a wide mint glow behind it, three faint diagonal planes.
/// Dark mode follows the Night Badge concept.
class WelcomeScreen extends StatefulWidget {
  /// Where the badge reads the time from; tests pass a fixed clock.
  final DateTime Function() clock;
  const WelcomeScreen({super.key, this.clock = DateTime.now});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _handoff =
      AnimationController(vsync: this, duration: kBadgeHandoff, reverseDuration: _handoffBack);

  /// Set from the first tap until the welcome is whole again, so Sign in opens once however often it is tapped.
  bool _leaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decoded now, so Sign in's first frame after the handoff is not held up by its art.
    precacheImage(const AssetImage('assets/branding/login_hero_art.png'), context);
  }

  @override
  void dispose() {
    _handoff.dispose();
    super.dispose();
  }

  Future<void> _startShift() async {
    if (_leaving) return;
    _leaving = true;
    final animate = !MediaQuery.disableAnimationsOf(context);
    if (animate) await _handoff.forward();
    if (!mounted) return;
    await context.push(AppRoutes.login);
    // Sign in stays opaque while it builds itself out; unwind only once it is gone, from the frame it left on.
    if (animate) await Future<void>.delayed(kSignInExit);
    if (mounted && animate) await _handoff.reverse();
    _leaving = false;
  }

  @override
  Widget build(BuildContext context) {
    final clock = widget.clock;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _Palette(isDark);
    // Everything but the badge leaves first.
    final rest = _handoff.drive(CurveTween(curve: const Interval(0, 0.3, curve: kSignInCurve)));
    Widget leaving(Widget child) =>
        AnimatedBuilder(animation: rest, builder: (_, child) => Opacity(opacity: 1 - rest.value, child: child), child: child);

    return AnimatedBuilder(
      animation: _handoff,
      // Light icons over the dark ground, and over Sign in's teal once the band has flooded halfway.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark || _handoff.value > 0.7 ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: child!,
      ),
      child: Scaffold(
        backgroundColor: palette.ground,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _PlanesPainter(palette, rest))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Hero(clock: clock, palette: palette, handoff: _handoff)),
                leaving(SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 27, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ShiftHeadline(clock: clock, palette: palette),
                        const SizedBox(height: 15),
                        Text(
                          'Pick up a device and make it yours for the shift.',
                          textAlign: TextAlign.center,
                          style: jakarta(14.5, 400, color: palette.muted, height: 1.42),
                        ),
                        const SizedBox(height: 31),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: palette.button,
                              foregroundColor: palette.onButton,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: jakarta(17, 800, letterSpacing: -0.4, height: 1.2),
                            ),
                            onPressed: _startShift,
                            child: const Text('Start my shift'),
                          ),
                        ),
                        const SizedBox(height: 17),
                        Text(
                          'Use your warehouse account to continue.',
                          textAlign: TextAlign.center,
                          style: jakarta(12, 400, color: palette.muted, letterSpacing: -0.1, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Plus Jakarta Sans at an exact weight. It is a variable font, so the weight is set on the `wght` axis too.
TextStyle jakarta(double size, int weight, {Color? color, double? letterSpacing, double? height}) => TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100 - 1).clamp(0, 8)],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

/// Light follows the "Morning shift" concept; dark follows "Night Badge".
class _Palette {
  final bool isDark;
  const _Palette(this.isDark);

  Color get ground => isDark ? const Color(0xFF111111) : const Color(0xFFEDF2F1);
  Color get ink => isDark ? const Color(0xFFEEEEEE) : const Color(0xFF003439);
  Color get muted => isDark ? const Color(0xFFA6B2B0) : const Color(0xFF5E6B69);
  Color get button => isDark ? const Color(0xFF00C896) : const Color(0xFF00796B);
  Color get onButton => isDark ? const Color(0xFF06201D) : Colors.white;
  Color get band => isDark ? const Color(0xFF00C896) : const Color(0xFF003439);
  Color get onBand => isDark ? const Color(0xFF111111) : Colors.white;
  List<Color> get card => isDark
      ? const [Color(0xFF242828), Color(0xFF1F2323), Color(0xFF1A1D1D)]
      : const [Colors.white, Color(0xFFFCFEFD), Color(0xFFF5FAF8)];
  Color get cardBorder => isDark ? const Color(0xFF323939) : const Color(0xFFD8E3DF).withValues(alpha: 0.65);
  Color get placeholder => isDark ? const Color(0xFF2B3030) : const Color(0xFFE6ECEA);
  Color get silhouette => isDark ? const Color(0xFF4C5654) : const Color(0xFFB7C2BF);
  double get glowStrength => isDark ? 1.6 : 0.8;

  /// The three planes: upper light, middle cool, lower light.
  List<Color> get planes => isDark
      ? const [Color(0xFF181B1B), Color(0xFF0B0C0C), Color(0xFF161919)]
      : [
          const Color(0xFFF7F9F8).withValues(alpha: 0.70),
          const Color(0xFFE3ECE9).withValues(alpha: 0.50),
          const Color(0xFFF6F9F8).withValues(alpha: 0.45),
        ];
}

/// Three low-contrast diagonal planes and a faint mint atmosphere, drawn to the 393 × 852 reference and stretched.
class _PlanesPainter extends CustomPainter {
  final _Palette palette;

  /// The handoff's fade of everything but the badge: the planes paint at 1 − its value. Faded here rather than under an
  /// Opacity, so the blurred planes are not drawn offscreen on every frame of the handoff.
  final Animation<double> leaving;
  _PlanesPainter(this.palette, this.leaving) : super(repaint: leaving);

  static const _polygons = [
    [Offset(0, 134), Offset(393, 0), Offset(393, 58), Offset(0, 186)],
    [Offset(0, 356), Offset(393, 500), Offset(393, 582), Offset(0, 438)],
    [Offset(0, 659), Offset(393, 498), Offset(393, 575), Offset(0, 744)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 393, sy = size.height / 852;
    for (var i = 0; i < _polygons.length; i++) {
      final path = Path()..addPolygon([for (final p in _polygons[i]) Offset(p.dx * sx, p.dy * sy)], true);
      canvas.drawPath(
        path,
        Paint()
          ..color = palette.planes[i].withValues(alpha: palette.planes[i].a * (1 - leaving.value))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6), // no hard edges
      );
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF54D3B4).withValues(alpha: 0.025 * (1 - leaving.value)),
    );
  }

  @override
  bool shouldRepaint(_PlanesPainter old) => old.palette.isDark != palette.isDark || old.leaving != leaving;
}

/// The lanyard, hardware and badge, with the glow behind. The badge's bottom sits just above the headline; the lanyard
/// runs from above the screen edge down through the badge's slot. On short phones the group scales down.
class _Hero extends StatelessWidget {
  final DateTime Function() clock;
  final _Palette palette;

  /// The badge handoff, 0 at rest to 1 when the screen is Sign in's background with its wordmark in place.
  final Animation<double> handoff;
  const _Hero({required this.clock, required this.palette, required this.handoff});

  static const double badgeW = 248, badgeH = 378, slotY = 16; // slot centre, from the badge top
  static const double slotW = 44, slotH = 10;
  static const double bandH = 87, bandWordmarkLeft = 25, bandWordmarkTop = 38, bandWordmarkW = 112;

  /// The hook's bend is ~12pt of metal: its bottom sits 7pt below the slot centre, so the inside of the bend rests on
  /// the slot's top edge, the way a card hangs from a real lanyard hook.
  static const double hookBottom = slotY + 7;

  /// How far the badge lifts as it straightens, and how far the lanyard pulls up.
  static const double lift = 8, pullUp = 190;

  static const _straighten = Interval(0, 0.45, curve: kSignInCurve);
  static const _glowOut = Interval(0, 0.3, curve: kSignInCurve);
  static const _badgeOut = Interval(0.4, 0.55);
  static const _flood = Interval(0.4, 1, curve: kSignInCurve);

  static const _lanyard = ExcludeSemantics(
    child: Image(
      image: AssetImage('assets/branding/lanyard.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final screen = MediaQuery.sizeOf(context);
    final badge = _Badge(clock: clock, palette: palette);
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth, h = constraints.maxHeight;
      // In the reference the badge ends 9pt above the hero's bottom and at least ~80pt of strap shows.
      final room = h - 9 - (topInset + 79);
      final scale = (room / badgeH).clamp(0.6, 1.0);
      final badgeTop = h - 9 - badgeH * scale;
      final cx = w / 2;
      final lanyardH = badgeTop + hookBottom * scale;
      final slotTop = badgeTop + (slotY - slotH / 2) * scale;
      // The hero starts at the screen's top-left, so its coordinates are the screen's: the flood can grow past it.
      final band = Rect.fromLTWH(cx - badgeW / 2 * scale, badgeTop - lift * scale, badgeW * scale, bandH * scale);
      final bandWordmark = Rect.fromLTWH(
        band.left + bandWordmarkLeft * scale,
        band.top + bandWordmarkTop * scale,
        bandWordmarkW * scale,
        bandWordmarkW * 241 / 828 * scale,
      );

      return AnimatedBuilder(
        animation: handoff,
        child: badge,
        builder: (context, badge) {
          final v = handoff.value;
          final straight = _straighten.transform(v);
          final flood = _flood.transform(v);
          // The strap and hook pull up and away together, keeping their cut through the slot.
          Widget pulled(Widget child) => Opacity(
                opacity: 1 - straight,
                child: Transform.translate(offset: Offset(0, -pullUp * straight), child: child),
              );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GlowPainter(
                    centre: Offset(cx, badgeTop + 242 * scale),
                    pool: Offset(cx, badgeTop + 372 * scale),
                    scale: scale,
                    // Faded through its own alpha, not an Opacity, so the wide blur is not redrawn offscreen.
                    strength: palette.glowStrength * (1 - _glowOut.transform(v)),
                  ),
                ),
              ),
              Positioned(
                left: cx - badgeW * scale / 2,
                top: badgeTop,
                width: badgeW * scale,
                height: badgeH * scale,
                child: Opacity(
                  opacity: 1 - _badgeOut.transform(v),
                  child: Transform.translate(
                    offset: Offset(0, -lift * scale * straight),
                    child: _Swing(
                      pivot: const Alignment(0, -1 + 2 * slotY / badgeH),
                      straighten: straight,
                      child: FittedBox(child: SizedBox(width: badgeW, height: badgeH, child: badge)),
                    ),
                  ),
                ),
              ),
              // Strap and hardware in front of the badge, down to the top of the slot. Over the card, only the hook's
              // shank (left) stays in front; its gate side (right) has gone through the slot and is behind the card.
              Positioned(
                left: cx - 36 * scale, // 72pt image; its strap is 52pt wide
                top: 0,
                width: 72 * scale,
                height: slotTop,
                child: pulled(ClipPath(
                  clipper: _ShankInFront(cardTop: badgeTop),
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: lanyardH,
                    maxHeight: lanyardH,
                    child: _lanyard,
                  ),
                )),
              ),
              // The hook's bend threaded through the slot: seen inside it, behind the card below it. The slot is cut
              // unrotated; the badge swings about the slot's centre, so it stays within a point or two of the hook.
              Positioned(
                left: cx - slotW / 2 * scale,
                top: slotTop,
                width: slotW * scale,
                height: slotH * scale,
                child: pulled(ClipRRect(
                  borderRadius: BorderRadius.circular(slotH / 2 * scale),
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: 72 * scale,
                    maxWidth: 72 * scale,
                    minHeight: lanyardH,
                    maxHeight: lanyardH,
                    child: Transform.translate(offset: Offset(-(36 - slotW / 2) * scale, -slotTop), child: _lanyard),
                  ),
                )),
              ),
              if (v >= _flood.begin) ...[
                // The band floods the screen and becomes Sign in's background.
                Positioned.fromRect(
                  rect: Rect.lerp(band, Offset.zero & screen, flood)!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18 * scale * (1 - flood))),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: kSignInGradient.begin,
                          end: kSignInGradient.end,
                          colors: [for (final c in kSignInGradient.colors) Color.lerp(palette.band, c, flood)!],
                        ),
                      ),
                    ),
                  ),
                ),
                // The band's wordmark flies to Sign in's header.
                Positioned.fromRect(
                  rect: Rect.lerp(
                    bandWordmark,
                    Rect.fromLTWH(
                      kSignInWordmarkInset.dx,
                      topInset + kSignInWordmarkInset.dy,
                      kSignInWordmarkHeight * 828 / 241,
                      kSignInWordmarkHeight,
                    ),
                    flood,
                  )!,
                  child: AturaWordmark(
                    height: lerpDouble(bandWordmark.height, kSignInWordmarkHeight, flood)!,
                    color: Color.lerp(palette.onBand, Colors.white, flood)!,
                  ),
                ),
              ],
            ],
          );
        },
      );
    });
  }
}

/// Everything above the card's top edge, and below it only the left half — the hook's shank. The edge follows the
/// badge's resting tilt (it rises to the right); during the settle swing it is off by a point at most.
class _ShankInFront extends CustomClipper<Path> {
  final double cardTop;
  const _ShankInFront({required this.cardTop});

  @override
  Path getClip(Size size) {
    final mid = size.width / 2;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, cardTop - mid * math.tan(-_Swing.rest))
      ..lineTo(mid, cardTop)
      ..lineTo(mid, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_ShankInFront old) => old.cardTop != cardTop;
}

/// On first show the badge settles with a small swing about its slot; reduced motion shows it at rest.
class _Swing extends StatelessWidget {
  final Alignment pivot;

  /// 0 hangs at its tilt; 1 hangs straight, as the badge does when Start my shift lifts it.
  final double straighten;
  final Widget child;
  const _Swing({required this.pivot, this.straighten = 0, required this.child});

  static const double rest = -4.2 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final swing = !MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: swing ? rest - 0.12 : rest, end: rest),
      duration: swing ? const Duration(milliseconds: 1400) : Duration.zero,
      curve: Curves.elasticOut,
      builder: (context, angle, child) =>
          Transform.rotate(angle: angle * (1 - straighten), alignment: pivot, child: child),
      child: child,
    );
  }
}

/// A wide, diffuse mint wash behind the badge and a smaller pool beneath it.
class _GlowPainter extends CustomPainter {
  final Offset centre, pool;
  final double scale, strength;
  _GlowPainter({required this.centre, required this.pool, required this.scale, required this.strength});

  @override
  void paint(Canvas canvas, Size size) {
    void glow(Offset c, double w, double h, Color color, double sigma) => canvas.drawOval(
          Rect.fromCenter(center: c, width: w * scale, height: h * scale),
          Paint()
            ..color = color
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma * scale),
        );
    glow(centre, 315, 365, const Color(0xFF00C896).withValues(alpha: (0.17 * strength).clamp(0, 1)), 55);
    glow(centre.translate(0, 20 * scale), 260, 300,
        const Color(0xFF54D3B4).withValues(alpha: (0.13 * strength).clamp(0, 1)), 45);
    glow(pool, 230, 90, const Color(0xFF54D3B4).withValues(alpha: (0.16 * strength).clamp(0, 1)), 38);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.centre != centre || old.pool != pool || old.scale != scale || old.strength != strength;
}

/// The badge card at its reference size (248 × 378); the hero scales it as a whole.
class _Badge extends StatelessWidget {
  final DateTime Function() clock;
  final _Palette palette;
  const _Badge({required this.clock, required this.palette});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: palette.card),
        border: Border.all(color: palette.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003439).withValues(alpha: palette.isDark ? 0.5 : 0.20),
            offset: const Offset(5, 18),
            blurRadius: 30,
            spreadRadius: -6,
          ),
          BoxShadow(color: const Color(0xFF111111).withValues(alpha: 0.09), offset: const Offset(0, 3), blurRadius: 7),
          // A mint glow hugging the edges, as in the concept, on top of the wide wash behind.
          BoxShadow(
              color: const Color(0xFF00C896).withValues(alpha: palette.isDark ? 0.55 : 0.36),
              blurRadius: 30,
              spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Faint A in the corner, as on a printed badge.
            Positioned(
              right: -34,
              bottom: -14,
              child:
                  AturaMark(width: 150, color: const Color(0xFF54D3B4).withValues(alpha: palette.isDark ? 0.10 : 0.14)),
            ),
            // Header band with the slot the hook goes through.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 87,
              child: ColoredBox(
                color: palette.band,
                child: Stack(
                  children: [
                    Positioned(
                      top: 11,
                      left: (248 - 44) / 2,
                      child: Container(
                        width: 44,
                        height: 10,
                        decoration: BoxDecoration(color: palette.ground, borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    Positioned(left: 25, top: 38, child: AturaWordmark(height: 112 * 241 / 828, color: palette.onBand)),
                  ],
                ),
              ),
            ),
            _BadgeFace(clock: clock, palette: palette),
            // Satin edge: a white catch-light top-left fading to a faint contact edge bottom-right.
            Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _EdgeLightPainter(palette.isDark)))),
          ],
        ),
      ),
    );
  }
}

class _EdgeLightPainter extends CustomPainter {
  final bool isDark;
  _EdgeLightPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(17.25)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.12 : 0.6),
            Colors.white.withValues(alpha: 0),
            const Color(0xFF003439).withValues(alpha: isDark ? 0.3 : 0.08),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_EdgeLightPainter old) => old.isDark != isDark;
}

/// Live clock, date, shift and the photo placeholder, at the reference positions. Rebuilds only when the minute
/// changes.
class _BadgeFace extends StatefulWidget {
  final DateTime Function() clock;
  final _Palette palette;
  const _BadgeFace({required this.clock, required this.palette});

  @override
  State<_BadgeFace> createState() => _BadgeFaceState();
}

class _BadgeFaceState extends State<_BadgeFace> {
  late DateTime _now = widget.clock();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = widget.clock();
      if (now.minute != _now.minute || now.hour != _now.hour) setState(() => _now = now);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final hour12 = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final minutes = _now.minute.toString().padLeft(2, '0');
    final meridiem = _now.hour < 12 ? 'AM' : 'PM';
    final (shift, shiftIcon) = shiftFor(_now);

    return Stack(
      children: [
        Positioned(
          left: 25,
          right: 20,
          top: 99,
          height: 52,
          // Shrinks rather than overflows with very large text settings.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$hour12:$minutes',
                    style: jakarta(48, 800, color: p.ink, letterSpacing: -2.0, height: 1.0)
                        .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                const SizedBox(width: 6),
                Text(meridiem, style: jakarta(26, 700, color: p.ink, letterSpacing: -0.7, height: 1.0)),
              ],
            ),
          ),
        ),
        Positioned(
          left: 27,
          right: 20,
          top: 159,
          child: Text('${_weekdays[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: jakarta(14, 500, color: p.muted, letterSpacing: -0.25, height: 1.3)),
        ),
        Positioned(
            left: 25, top: 189, width: 198, height: 1, child: ColoredBox(color: p.muted.withValues(alpha: 0.22))),
        Positioned(left: 27, top: 205, child: Icon(shiftIcon, size: 22, color: const Color(0xFF00C896))),
        Positioned(
          left: 57,
          right: 20,
          top: 207,
          child: Text(shift,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: jakarta(15, 700, color: p.ink, letterSpacing: -0.4, height: 1.2)),
        ),
        Positioned(left: 79, top: 239, child: _PhotoPlaceholder(palette: p)),
        Positioned(
          left: 0,
          right: 0,
          top: 338,
          child:
              Text('A0001', textAlign: TextAlign.center, style: jakarta(11, 500, color: p.muted, height: 1.3)),
        ),
      ],
    );
  }
}

/// A plain grey photo placeholder: the badge is waiting for whoever signs in.
class _PhotoPlaceholder extends StatelessWidget {
  final _Palette palette;
  const _PhotoPlaceholder({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(color: palette.placeholder, borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.bottomCenter,
      child: ExcludeSemantics(child: Icon(Icons.person_rounded, size: 86, color: palette.silhouette)),
    );
  }
}

/// "Morning shift?" / "We've got you." — follows the shift, read once when the screen opens.
class _ShiftHeadline extends StatelessWidget {
  final DateTime Function() clock;
  final _Palette palette;
  const _ShiftHeadline({required this.clock, required this.palette});

  @override
  Widget build(BuildContext context) {
    final (shift, _) = shiftFor(clock());
    return Text(
      "$shift?\nWe've got you.", // always two balanced lines
      textAlign: TextAlign.center,
      style: jakarta(29, 800, color: palette.ink, letterSpacing: -1.15, height: 1.12),
    );
  }
}

/// Morning 6:00–13:59, afternoon 14:00–21:59, night the rest.
(String, IconData) shiftFor(DateTime t) {
  if (t.hour >= 6 && t.hour < 14) return ('Morning shift', Icons.wb_sunny);
  if (t.hour >= 14 && t.hour < 22) return ('Afternoon shift', Icons.wb_twilight);
  return ('Night shift', Icons.nightlight_round);
}
