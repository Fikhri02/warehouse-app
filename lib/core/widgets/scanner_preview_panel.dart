import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../router/app_route_observer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ScannerPreviewPermissionState {
  checking,
  granted,
  denied,
  permanentlyDenied,
}

class ScannerPreviewPanel extends StatefulWidget {
  final FutureOr<void> Function(BarcodeCapture capture) onDetect;
  final double collapsedHeight;
  final double expandedHeight;
  final bool paused;
  final String pausedLabel;
  final Widget? bottomRightOverlay;
  final ValueChanged<bool>? onExpandedChanged;

  const ScannerPreviewPanel({
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
  State<ScannerPreviewPanel> createState() => _ScannerPreviewPanelState();
}

class _ScannerPreviewPanelState extends State<ScannerPreviewPanel>
    with RouteAware {
  static const double _previewSwipeVelocityThreshold = 250;

  final MobileScannerController _scannerController = MobileScannerController();
  bool _isRouteVisible = true;
  bool _isExpanded = false;
  bool _keepExpanded = false;
  bool _didResetZoomScale = false;
  int _scannerMountVersion = 0;
  double? _zoomScaleAtGestureStart;
  ScannerPreviewPermissionState _permissionState =
      ScannerPreviewPermissionState.checking;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refreshPermissionState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.unsubscribe(this);
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (!mounted) return;
    setState(() => _isRouteVisible = false);
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    setState(() {
      _isRouteVisible = true;
      _didResetZoomScale = false;
      _scannerMountVersion++;
    });
    Future.microtask(_refreshPermissionState);
  }

  Future<void> _refreshPermissionState() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    final nextState = switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited =>
        ScannerPreviewPermissionState.granted,
      PermissionStatus.permanentlyDenied ||
      PermissionStatus.restricted =>
        ScannerPreviewPermissionState.permanentlyDenied,
      _ => ScannerPreviewPermissionState.denied,
    };
    setState(() => _permissionState = nextState);
  }

  Future<void> _requestPermission() async {
    setState(() => _permissionState = ScannerPreviewPermissionState.checking);
    await Permission.camera.request();
    await _refreshPermissionState();
  }

  void _notifyExpandedChanged() {
    widget.onExpandedChanged?.call(_isExpanded);
  }

  void _toggleExpansion() {
    setState(() {
      if (_isExpanded) {
        _isExpanded = false;
        _keepExpanded = false;
      } else {
        _isExpanded = true;
        _keepExpanded = false;
      }
    });
    _notifyExpandedChanged();
  }

  void _togglePinnedExpansion() {
    setState(() {
      _isExpanded = true;
      _keepExpanded = !_keepExpanded;
    });
    _notifyExpandedChanged();
  }

  void _handleSwipeDown() {
    setState(() {
      if (!_isExpanded) {
        _isExpanded = true;
        _keepExpanded = false;
      } else {
        _keepExpanded = true;
      }
    });
    _notifyExpandedChanged();
  }

  void _handleSwipeUp() {
    if (!_isExpanded && !_keepExpanded) return;
    setState(() {
      _isExpanded = false;
      _keepExpanded = false;
    });
    _notifyExpandedChanged();
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null) return;
    if (velocity > _previewSwipeVelocityThreshold) {
      _handleSwipeDown();
      return;
    }
    if (velocity < -_previewSwipeVelocityThreshold) {
      _handleSwipeUp();
    }
  }

  Future<void> _setZoomScale(double zoomScale) async {
    if (!_scannerController.value.isInitialized ||
        !_scannerController.value.isRunning) {
      return;
    }
    await _scannerController.setZoomScale(zoomScale.clamp(0.0, 1.0));
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;
    _zoomScaleAtGestureStart = _scannerController.value.zoomScale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;
    final baseZoom =
        _zoomScaleAtGestureStart ?? _scannerController.value.zoomScale;
    final nextZoom = (baseZoom + ((details.scale - 1) * 0.35)).clamp(0.0, 1.0);
    unawaited(_setZoomScale(nextZoom));
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _zoomScaleAtGestureStart = null;
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isExpanded && !_keepExpanded) {
      setState(() => _isExpanded = false);
      _notifyExpandedChanged();
    }
    await widget.onDetect(capture);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cameraHeight =
        _isExpanded ? widget.expandedHeight : widget.collapsedHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: cameraHeight,
      child: switch (_permissionState) {
        ScannerPreviewPermissionState.checking =>
          const Center(child: CircularProgressIndicator()),
        ScannerPreviewPermissionState.granted => _buildGrantedState(brightness),
        ScannerPreviewPermissionState.denied => _PermissionPanel(
            title: 'Camera permission needed',
            message:
                'Allow camera access to scan barcodes, or use manual entry to keep counting.',
            actionLabel: 'Allow Camera',
            onAction: _requestPermission,
            brightness: brightness,
          ),
        ScannerPreviewPermissionState.permanentlyDenied => _PermissionPanel(
            title: 'Camera access is blocked',
            message:
                'Enable camera access from system settings to resume barcode scanning.',
            actionLabel: 'Open Settings',
            onAction: () async {
              await openAppSettings();
            },
            brightness: brightness,
          ),
      },
    );
  }

  Widget _buildGrantedState(Brightness brightness) {
    if (!_isRouteVisible) {
      return Container(color: Colors.black);
    }

    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: _scannerController,
      builder: (context, scannerState, _) {
        if (scannerState.isInitialized &&
            scannerState.isRunning &&
            !_didResetZoomScale) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted ||
                _didResetZoomScale ||
                !_scannerController.value.isInitialized ||
                !_scannerController.value.isRunning) {
              return;
            }
            _didResetZoomScale = true;
            unawaited(_scannerController.resetZoomScale());
          });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: _handleVerticalDragEnd,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              child: MobileScanner(
                key: ValueKey('scanner-$_scannerMountVersion'),
                controller: _scannerController,
                onDetect: _handleDetect,
                errorBuilder: (context, error, child) => Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Camera preview unavailable',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        error.errorCode.name,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _didResetZoomScale = false;
                            _scannerMountVersion++;
                          });
                          _refreshPermissionState();
                        },
                        child: const Text('Retry Camera'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  _CameraControlButton(
                    icon: scannerState.torchState == TorchState.on
                        ? Icons.flashlight_on_rounded
                        : Icons.flashlight_off_rounded,
                    tooltip: scannerState.torchState == TorchState.unavailable
                        ? 'Torch unavailable'
                        : scannerState.torchState == TorchState.on
                            ? 'Turn torch off'
                            : 'Turn torch on',
                    selected: scannerState.torchState == TorchState.on,
                    enabled: scannerState.torchState != TorchState.unavailable,
                    onPressed: () =>
                        unawaited(_scannerController.toggleTorch()),
                  ),
                  const SizedBox(height: 8),
                  _CameraControlButton(
                    icon: _keepExpanded
                        ? Icons.push_pin_outlined
                        : _isExpanded
                            ? Icons.unfold_less
                            : Icons.unfold_more,
                    tooltip: _keepExpanded
                        ? 'Pinned open'
                        : _isExpanded
                            ? 'Collapse camera preview'
                            : 'Expand camera preview',
                    selected: _isExpanded,
                    onPressed: _toggleExpansion,
                    onDoubleTap: _togglePinnedExpansion,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _ZoomControlBar(
                      zoomScale: scannerState.zoomScale,
                      enabled:
                          scannerState.isInitialized && scannerState.isRunning,
                      onChanged: (value) => unawaited(_setZoomScale(value)),
                    ),
                  ),
                  if (widget.bottomRightOverlay != null) ...[
                    const SizedBox(width: 12),
                    widget.bottomRightOverlay!,
                  ],
                ],
              ),
            ),
            if (widget.paused)
              Container(
                color: Colors.black.withValues(alpha: 0.28),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.pausedLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CameraControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final VoidCallback? onDoubleTap;

  const _CameraControlButton({
    required this.icon,
    required this.tooltip,
    this.selected = false,
    this.enabled = true,
    this.onPressed,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected
        ? AppColors.primary.withValues(alpha: 0.92)
        : Colors.black.withValues(alpha: 0.42);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? backgroundColor : Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          onDoubleTap: enabled ? onDoubleTap : null,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 20,
              color: enabled ? Colors.white : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomControlBar extends StatelessWidget {
  final double zoomScale;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _ZoomControlBar({
    required this.zoomScale,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.zoom_out_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.55),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                activeTrackColor: Colors.white.withValues(alpha: 0.7),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                thumbColor: Colors.white.withValues(alpha: 0.82),
                overlayColor: Colors.white.withValues(alpha: 0.08),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: zoomScale.clamp(0.0, 1.0),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
          Icon(
            Icons.zoom_in_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

class _PermissionPanel extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;
  final Brightness brightness;

  const _PermissionPanel({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceFor(brightness),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 36,
            color: AppColors.textSecondary(brightness),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary(brightness),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
