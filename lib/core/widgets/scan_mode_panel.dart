import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'scanner_preview_panel.dart';

enum ScanMode { oneSnap, bulk, threeSecDelay }

class ScanModePanel extends StatefulWidget {
  final FutureOr<void> Function(BarcodeCapture capture) onDetect;
  final double collapsedHeight;
  final double expandedHeight;
  final bool paused;
  final String pausedLabel;
  final Widget? bottomRightOverlay;
  final ValueChanged<bool>? onExpandedChanged;

  const ScanModePanel({
    required this.onDetect,
    required this.collapsedHeight,
    required this.expandedHeight,
    this.paused = false,
    this.pausedLabel = 'Scan paused',
    this.bottomRightOverlay,
    this.onExpandedChanged,
    super.key,
  });

  @override
  State<ScanModePanel> createState() => _ScanModePanelState();
}

class _ScanModePanelState extends State<ScanModePanel> {
  static const List<ScanMode> _modeOrder = <ScanMode>[
    ScanMode.oneSnap,
    ScanMode.bulk,
    ScanMode.threeSecDelay,
  ];
  static const double _swipeVelocityThreshold = 220;
  static const Duration _modePillDuration = Duration(milliseconds: 1500);
  static const Duration _delayDuration = Duration(seconds: 3);
  static const Duration _countdownTick = Duration(milliseconds: 100);

  ScanMode _mode = ScanMode.bulk;
  bool _oneSnapArmed = false;
  bool _showModePill = true;
  Timer? _modePillTimer;
  Timer? _countdownTimer;
  int _countdownRemainingMs = 0;

  bool get _isCountingDown => _countdownRemainingMs > 0;

  double get _countdownProgress {
    if (!_isCountingDown) return 0;
    return _countdownRemainingMs / _delayDuration.inMilliseconds;
  }

  double get _countdownSeconds {
    if (!_isCountingDown) return 0;
    return _countdownRemainingMs / 1000;
  }

  @override
  void initState() {
    super.initState();
    _showModePillTemporarily();
  }

  @override
  void dispose() {
    _modePillTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (widget.paused) return;

    switch (_mode) {
      case ScanMode.oneSnap:
        if (!_oneSnapArmed) return;
        setState(() => _oneSnapArmed = false);
        await widget.onDetect(capture);
        return;
      case ScanMode.bulk:
        await widget.onDetect(capture);
        return;
      case ScanMode.threeSecDelay:
        if (_isCountingDown) return;
        await widget.onDetect(capture);
        if (!mounted) return;
        _startCountdown();
        return;
    }
  }

  void _showModePillTemporarily() {
    _modePillTimer?.cancel();
    if (!_showModePill && mounted) {
      setState(() => _showModePill = true);
    }
    _modePillTimer = Timer(_modePillDuration, () {
      if (!mounted) return;
      setState(() => _showModePill = false);
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdownRemainingMs = _delayDuration.inMilliseconds);
    _countdownTimer = Timer.periodic(_countdownTick, (timer) {
      final nextMs = _countdownRemainingMs - _countdownTick.inMilliseconds;
      if (nextMs <= 0) {
        timer.cancel();
        if (!mounted) return;
        setState(() => _countdownRemainingMs = 0);
        return;
      }
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdownRemainingMs = nextMs);
    });
  }

  void _changeMode(int offset) {
    final currentIndex = _modeOrder.indexOf(_mode);
    final nextIndex = (currentIndex + offset).clamp(0, _modeOrder.length - 1);
    if (nextIndex == currentIndex) {
      _showModePillTemporarily();
      return;
    }

    _countdownTimer?.cancel();
    setState(() {
      _mode = _modeOrder[nextIndex];
      _countdownRemainingMs = 0;
      _oneSnapArmed = false;
      _showModePill = true;
    });
    _showModePillTemporarily();
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null || velocity.abs() < _swipeVelocityThreshold) return;
    if (velocity < 0) {
      _changeMode(1);
    } else {
      _changeMode(-1);
    }
  }

  void _armOneSnapMode() {
    if (_mode != ScanMode.oneSnap) return;
    setState(() => _oneSnapArmed = true);
    _showModePillTemporarily();
  }

  String get _modeLabel => switch (_mode) {
        ScanMode.oneSnap => 'ONE-SNAP',
        ScanMode.bulk => 'BULK',
        ScanMode.threeSecDelay => '3S DELAY',
      };

  Color get _modePillColor => switch (_mode) {
        ScanMode.bulk => Colors.black.withValues(alpha: 0.48),
        _ => AppColors.primary.withValues(alpha: 0.94),
      };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScannerPreviewPanel(
          collapsedHeight: widget.collapsedHeight,
          expandedHeight: widget.expandedHeight,
          paused: widget.paused,
          pausedLabel: widget.pausedLabel,
          bottomRightOverlay: widget.bottomRightOverlay,
          onExpandedChanged: widget.onExpandedChanged,
          onDetect: _handleDetect,
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: _handleHorizontalDragEnd,
          ),
        ),
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showModePill ? 1 : 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _modePillColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    _modeLabel,
                    style: AppTextStyles.micro.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_mode == ScanMode.oneSnap && !_oneSnapArmed)
          _OneSnapOverlay(
            onTap: _armOneSnapMode,
          ),
        if (_mode == ScanMode.threeSecDelay && _isCountingDown)
          _ThreeSecondDelayOverlay(
            secondsRemaining: _countdownSeconds,
            progress: _countdownProgress,
          ),
      ],
    );
  }
}

class _OneSnapOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const _OneSnapOverlay({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.24),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.46),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.center_focus_strong_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TAP TO SCAN NEXT',
                        style: AppTextStyles.micro.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'One scan will arm, detect once, then freeze again.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreeSecondDelayOverlay extends StatelessWidget {
  final double secondsRemaining;
  final double progress;

  const _ThreeSecondDelayOverlay({
    required this.secondsRemaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.36),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.46),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.clamp(0, 1),
                        strokeWidth: 5,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                      ),
                      Center(
                        child: Text(
                          secondsRemaining.toStringAsFixed(1),
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'NEXT SCAN IN',
                  style: AppTextStyles.micro.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Additional detections are ignored during the delay window.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
