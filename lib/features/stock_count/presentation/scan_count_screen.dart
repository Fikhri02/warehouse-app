import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/models/count_session.dart';
import '../../../core/router/app_route_observer.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/qty_adjuster.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/stock_count_provider.dart';

enum _CameraPermissionUiState { checking, granted, denied, permanentlyDenied }

class ScanCountScreen extends ConsumerStatefulWidget {
  const ScanCountScreen({super.key});

  @override
  ConsumerState<ScanCountScreen> createState() => _ScanCountScreenState();
}

class _ScanCountScreenState extends ConsumerState<ScanCountScreen>
    with RouteAware {
  final Set<String> _skipDuplicateWarnings = <String>{};
  ({String code, String name})? _scanned;
  int _qty = 0;
  bool _scanning = true;
  bool _isRouteVisible = true;
  int _scannerMountVersion = 0;
  _CameraPermissionUiState _permissionState = _CameraPermissionUiState.checking;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
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
    WakelockPlus.disable();
    appRouteObserver.unsubscribe(this);
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
        _CameraPermissionUiState.granted,
      PermissionStatus.permanentlyDenied ||
      PermissionStatus.restricted =>
        _CameraPermissionUiState.permanentlyDenied,
      _ => _CameraPermissionUiState.denied,
    };
    setState(() => _permissionState = nextState);
  }

  Future<void> _requestPermission() async {
    setState(() => _permissionState = _CameraPermissionUiState.checking);
    await Permission.camera.request();
    await _refreshPermissionState();
  }

  Future<void> _resumeScanning() async {
    setState(() {
      _scanned = null;
      _qty = 0;
      _scanning = true;
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _permissionState != _CameraPermissionUiState.granted) {
      return;
    }
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() => _scanning = false);
    try {
      final name = await ref
          .read(stockCountRepositoryProvider)
          .lookupItemByBarcode(code);
      if (!mounted) return;
      if (name == null) {
        final addManually = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            actionsAlignment: MainAxisAlignment.end,
            title: const Text('Item not recognized'),
            content: Text('$code was not found. Add it manually instead?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Add Manually'),
              ),
            ],
          ),
        );
        if (addManually == true) {
          await _openManualEntry(initialCode: code);
        } else {
          await _resumeScanning();
        }
        return;
      }
      setState(() {
        _scanned = (code: code, name: name);
        _qty = 1;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error looking up item — please try again')),
      );
      await _resumeScanning();
    }
  }

  Future<void> _confirmItem() async {
    final item = _scanned;
    if (item == null) return;
    await _addItem(
      CountItem(
        itemCode: item.code,
        itemName: item.name,
        expected: 0,
        counted: _qty,
        entryMethod: CountEntryMethod.scanned,
      ),
    );
  }

  Future<void> _openManualEntry({String? initialCode}) async {
    final item = await context.push<CountItem>(
      AppRoutes.stockCountManualEntry,
      extra: initialCode,
    );
    if (item == null || !mounted) {
      await _resumeScanning();
      return;
    }
    await _addItem(item);
  }

  Future<void> _addItem(CountItem item) async {
    final session = ref.read(stockCountNotifierProvider);
    final isDuplicate =
        session?.items.any((e) => e.itemCode == item.itemCode) ?? false;
    if (isDuplicate && !_skipDuplicateWarnings.contains(item.itemCode)) {
      final choice = await _showDuplicateDialog(item);
      if (choice == null || !choice.add) {
        await _resumeScanning();
        return;
      }
      if (choice.neverAskAgain) {
        setState(() => _skipDuplicateWarnings.add(item.itemCode));
      }
    }

    await ref.read(stockCountNotifierProvider.notifier).addItem(item);
    if (!mounted) return;

    if (ref.read(profileSettingsProvider).hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }

    // Capture notifier and messenger before any potential dispose —
    // SnackBar callbacks fire after the widget may be gone.
    final notifier = ref.read(stockCountNotifierProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.itemName} added'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => notifier.removeItem(item.id),
          ),
        ),
      );

    await _resumeScanning();
  }

  Future<({bool add, bool neverAskAgain})?> _showDuplicateDialog(
    CountItem item,
  ) {
    bool neverAskAgain = false;
    return showDialog<({bool add, bool neverAskAgain})>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Duplicate item detected'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.itemCode} is already in this session. Add another count entry?',
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: neverAskAgain,
                onChanged: (v) =>
                    setDialogState(() => neverAskAgain = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: const Text('Never ask again for this item this session'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop((add: false, neverAskAgain: false)),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context)
                  .pop((add: true, neverAskAgain: neverAskAgain)),
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editItemQty(CountItem item) async {
    int newQty = item.counted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.itemName, style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text(
                item.itemCode,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              QtyAdjuster(
                value: newQty,
                onChanged: (v) => setDialogState(() => newQty = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(stockCountNotifierProvider.notifier)
          .updateItemQty(item.id, newQty);
    }
  }

  Future<void> _removeItem(CountItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text(
          'Remove ${item.itemName} (${item.itemCode}) from this count?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(stockCountNotifierProvider.notifier)
          .removeItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(stockCountNotifierProvider);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Items')),
        body: SafeArea(
          top: false,
          minimum: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'No active count session.',
                textAlign: TextAlign.center,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              Text(
                'Start or resume a stock count session before scanning items.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary(Theme.of(context).brightness),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.stockCount),
                child: const Text('Go to Stock Count'),
              ),
            ],
          ),
        ),
      );
    }

    final items = session.items;
    final totalUnits = items.fold(0, (sum, i) => sum + i.counted);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          session.location.isEmpty ? 'Scan Items' : session.location,
        ),
        actions: [
          if (items.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${items.length} items · $totalUnits units',
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: _buildCameraPanel(brightness),
            ),
            Expanded(
              child: _scanned != null
                  ? _buildConfirmPanel(brightness)
                  : items.isEmpty
                      ? _buildHint(brightness)
                      : _buildItemsList(items, brightness),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_scanned == null)
                    OutlinedButton.icon(
                      onPressed: _openManualEntry,
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: const Text('Manual Entry'),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: items.isNotEmpty
                        ? () => context.push(AppRoutes.stockCountReview)
                        : null,
                    child: const Text('Finish Session'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHint(Brightness brightness) {
    return Center(
      child: Text(
        'Point camera at barcode',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary(brightness),
        ),
      ),
    );
  }

  Widget _buildConfirmPanel(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _scanned!.code,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_scanned!.name, style: AppTextStyles.title),
                  const SizedBox(height: 16),
                  QtyAdjuster(
                    value: _qty,
                    onChanged: (v) => setState(() => _qty = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resumeScanning,
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _confirmItem,
                  child: const Text('Confirm Item'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openManualEntry,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Enter Item Manually'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<CountItem> items, Brightness brightness) {
    // Map itemCode → count of occurrences for duplicate badge
    final codeCounts = <String, int>{};
    for (final item in items) {
      codeCounts[item.itemCode] = (codeCounts[item.itemCode] ?? 0) + 1;
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[items.length - 1 - index]; // newest first
        final dupCount = codeCounts[item.itemCode] ?? 1;
        return _CountedItemRow(
          item: item,
          dupCount: dupCount,
          brightness: brightness,
          onEdit: () => _editItemQty(item),
          onRemove: () => _removeItem(item),
        );
      },
    );
  }

  Widget _buildCameraPanel(Brightness brightness) {
    switch (_permissionState) {
      case _CameraPermissionUiState.checking:
        return const Center(child: CircularProgressIndicator());
      case _CameraPermissionUiState.granted:
        if (!_isRouteVisible) {
          return Container(color: Colors.black);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              key: ValueKey('scanner-$_scannerMountVersion'),
              onDetect: _onDetect,
              errorBuilder: (context, error, child) => Container(
                color: Colors.black,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 32),
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
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _scannerMountVersion++);
                        _refreshPermissionState();
                      },
                      child: const Text('Retry Camera'),
                    ),
                  ],
                ),
              ),
            ),
            if (!_scanning)
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
                  child: const Text(
                    'Scan paused while reviewing item',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      case _CameraPermissionUiState.denied:
        return _PermissionPanel(
          title: 'Camera permission needed',
          message:
              'Allow camera access to scan barcodes, or use manual entry to keep counting.',
          actionLabel: 'Allow Camera',
          onAction: _requestPermission,
          brightness: brightness,
        );
      case _CameraPermissionUiState.permanentlyDenied:
        return _PermissionPanel(
          title: 'Camera access is blocked',
          message:
              'Enable camera access from system settings to resume barcode scanning.',
          actionLabel: 'Open Settings',
          onAction: () async => openAppSettings(),
          brightness: brightness,
        );
    }
  }
}

class _CountedItemRow extends StatelessWidget {
  final CountItem item;
  final int dupCount;
  final Brightness brightness;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _CountedItemRow({
    required this.item,
    required this.dupCount,
    required this.brightness,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.itemName,
                          style: AppTextStyles.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _SmallBadge(
                        label: item.entryMethod == CountEntryMethod.scanned
                            ? 'scanned'
                            : 'typed',
                      ),
                      if (dupCount > 1) ...[
                        const SizedBox(width: 4),
                        _SmallBadge(label: '×$dupCount'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.itemCode,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                      if (item.expected > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.variance >= 0
                              ? '+${item.variance}'
                              : '${item.variance}',
                          style: AppTextStyles.caption.copyWith(
                            color: item.matched
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${item.counted}',
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 20),
              visualDensity: VisualDensity.compact,
              tooltip: 'Edit quantity',
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.error),
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove item',
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;

  const _SmallBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.micro.copyWith(
          color: AppColors.textSecondary(brightness),
        ),
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
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary(brightness)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => onAction(),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
