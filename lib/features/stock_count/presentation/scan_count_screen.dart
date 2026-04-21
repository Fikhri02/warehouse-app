import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/haptics.dart';
import '../../../core/models/count_session.dart';
import '../../../core/models/location.dart';
import '../../../core/models/worker.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/qty_adjuster.dart';
import '../../../core/widgets/scan_mode_panel.dart';
import '../../../data/sample/sample_locations.dart';
import '../../../data/sample/sample_workers.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/stock_count_provider.dart';

class ScanCountScreen extends ConsumerStatefulWidget {
  const ScanCountScreen({super.key});

  @override
  ConsumerState<ScanCountScreen> createState() => _ScanCountScreenState();
}

class _ScanCountScreenState extends ConsumerState<ScanCountScreen> {
  static const double _collapsedCameraHeight = 240;

  final ScanModeController _scanModeController = ScanModeController();
  final Set<String> _skipDuplicateWarnings = <String>{};
  DateTime? _lastBackPressAt;
  ({String code, String name})? _scanned;
  int _qty = 0;
  bool _scanning = true;
  bool _isCameraExpanded = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _resumeScanning() async {
    setState(() {
      _scanned = null;
      _qty = 0;
      _scanning = true;
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
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
      triggerScanHapticFeedback();
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
      await ref.read(stockCountNotifierProvider.notifier).removeItem(item.id);
    }
  }

  void _handleBackPress() {
    final now = DateTime.now();
    final shouldLeave = _lastBackPressAt != null &&
        now.difference(_lastBackPressAt!) <= const Duration(seconds: 2);

    if (shouldLeave) {
      context.go(AppRoutes.dashboard);
      return;
    }

    _lastBackPressAt = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Press back again to go to Home'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _showSessionPreview(CountSession session) async {
    final brightness = Theme.of(context).brightness;
    final location = _findLocation(session.locationId);
    final worker = _findWorker(session.assignedWorkerId);
    final localizations = MaterialLocalizations.of(context);
    final startedDate = localizations.formatMediumDate(session.startedAt);
    final startedTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(session.startedAt),
      alwaysUse24HourFormat: true,
    );
    final deadline = session.deadline == null
        ? 'No deadline'
        : localizations.formatMediumDate(session.deadline!);
    final totalUnits = session.items.fold(0, (sum, item) => sum + item.counted);

    await showDialog<void>(
      context: context,
      builder: (context) => _SessionInfoDialog(
        brightness: brightness,
        location: location?.name ?? session.location,
        zoneAisle: session.zoneAisle ?? '—',
        assignedWorker: worker?.name ?? 'Unassigned',
        deadline: deadline,
        startedAt: '$startedDate, $startedTime',
        progress: '${session.items.length} items · $totalUnits units',
      ),
    );
  }

  Location? _findLocation(String? locationId) {
    if (locationId == null) return null;
    for (final location in sampleLocations) {
      if (location.id == locationId) return location;
    }
    return null;
  }

  Worker? _findWorker(String? workerId) {
    if (workerId == null) return null;
    for (final worker in sampleWorkers) {
      if (worker.id == workerId) return worker;
    }
    return null;
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
    final brightness = Theme.of(context).brightness;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _handleBackPress),
          title: Text(
            session.location.isEmpty ? 'Scan Items' : session.location,
          ),
          actions: [
            IconButton(
              onPressed: () => _showSessionPreview(session),
              icon: const Icon(Icons.info_outline),
              tooltip: 'Session information',
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final actionsBar = SafeArea(
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
              );

              final bottomInsets = MediaQuery.paddingOf(context).bottom;
              final actionBarHeight =
                  _scanned == null ? 120.0 + bottomInsets : 72.0 + bottomInsets;
              final expandedCameraHeight = math.max(
                constraints.maxHeight - actionBarHeight,
                _collapsedCameraHeight,
              );

              return ScanModeSurface(
                controller: _scanModeController,
                child: Column(
                  children: [
                    ScanModePanel(
                      controller: _scanModeController,
                      collapsedHeight: _collapsedCameraHeight,
                      expandedHeight: expandedCameraHeight,
                      // paused: !_scanning,
                      // pausedLabel: 'Scan paused while reviewing item',
                      onExpandedChanged: (isExpanded) {
                        if (_isCameraExpanded == isExpanded) return;
                        setState(() => _isCameraExpanded = isExpanded);
                      },
                      onDetect: _onDetect,
                    ),
                    if (!_isCameraExpanded)
                      Expanded(
                        child: _scanned != null
                            ? _buildConfirmPanel(brightness)
                            : items.isEmpty
                                ? _buildHint(brightness)
                                : _buildItemsList(items, brightness),
                      ),
                    actionsBar,
                  ],
                ),
              );
            },
          ),
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

class _SessionInfoDialog extends StatelessWidget {
  final Brightness brightness;
  final String location;
  final String zoneAisle;
  final String assignedWorker;
  final String deadline;
  final String startedAt;
  final String progress;

  const _SessionInfoDialog({
    required this.brightness,
    required this.location,
    required this.zoneAisle,
    required this.assignedWorker,
    required this.deadline,
    required this.startedAt,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Information',
                            style: AppTextStyles.display.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current session snapshot',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(10),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: AppColors.surfaceFor(brightness),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PreviewRow(
                      label: 'Location',
                      value: location,
                      brightness: brightness,
                    ),
                    _PreviewRow(
                      label: 'Zone / Aisle',
                      value: zoneAisle,
                      brightness: brightness,
                    ),
                    _PreviewRow(
                      label: 'Assigned worker',
                      value: assignedWorker,
                      brightness: brightness,
                    ),
                    _PreviewRow(
                      label: 'Deadline',
                      value: deadline,
                      brightness: brightness,
                    ),
                    _PreviewRow(
                      label: 'Started',
                      value: startedAt,
                      brightness: brightness,
                    ),
                    _PreviewRow(
                      label: 'Count progress',
                      value: progress,
                      brightness: brightness,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Brightness brightness;

  const _PreviewRow({
    required this.label,
    required this.value,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary(brightness),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
