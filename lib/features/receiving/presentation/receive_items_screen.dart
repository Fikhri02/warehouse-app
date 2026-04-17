import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/models/purchase_order.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/receiving_provider.dart';

class ReceiveItemsScreen extends ConsumerStatefulWidget {
  const ReceiveItemsScreen({super.key});

  @override
  ConsumerState<ReceiveItemsScreen> createState() => _ReceiveItemsScreenState();
}

class _ReceiveItemsScreenState extends ConsumerState<ReceiveItemsScreen> {
  final MobileScannerController _scanner = MobileScannerController();
  bool _processingBarcode = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processingBarcode) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    _processingBarcode = true;
    final found =
        ref.read(activeReceiveNotifierProvider.notifier).scanItem(barcode);
    if (!found) {
      _showUnknownItemDialog(barcode);
    } else {
      Future<void>.delayed(
        const Duration(milliseconds: 800),
        () => _processingBarcode = false,
      );
    }
  }

  Future<void> _showUnknownItemDialog(String barcode) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item Not Found'),
        content: Text('$barcode is not in this PO. Add anyway?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(activeReceiveNotifierProvider.notifier).addUnknownItem(
                    itemCode: barcode,
                    itemName: barcode,
                    qty: 1,
                  );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    _processingBarcode = false;
  }

  Future<void> _showFlagDialog(PoLineItem item) async {
    String? selectedReason;
    const reasons = [
      'Damaged / Poor condition',
      'Wrong item delivered',
      'Quantity mismatch',
      'Other',
    ];

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Flag Issue - ${item.itemName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons
                .map(
                  (reason) => InkWell(
                    onTap: () => setDialogState(() => selectedReason = reason),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            selectedReason == reason
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 18,
                            color: selectedReason == reason
                                ? AppColors.primary
                                : AppColors.subtitle,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(reason, style: AppTextStyles.body),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      ref
                          .read(activeReceiveNotifierProvider.notifier)
                          .flagItemWithReason(
                            itemCode: item.itemCode,
                            reason: selectedReason!,
                          );
                    },
              child: const Text('Confirm Flag'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManualEntryDialog() async {
    final codeController = TextEditingController();
    final qtyController = TextEditingController(text: '1');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Item code'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Qty'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = codeController.text.trim();
              final qty = int.tryParse(qtyController.text) ?? 1;
              if (code.isEmpty) return;

              Navigator.of(context).pop();
              final found = ref
                  .read(activeReceiveNotifierProvider.notifier)
                  .scanItem(code);
              if (!found) {
                ref.read(activeReceiveNotifierProvider.notifier).addUnknownItem(
                      itemCode: code,
                      itemName: code,
                      qty: qty,
                    );
              } else {
                ref.read(activeReceiveNotifierProvider.notifier).confirmItem(
                      itemCode: code,
                      received: qty,
                    );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    codeController.dispose();
    qtyController.dispose();
  }

  Future<void> _onProceed(PurchaseOrder order) async {
    final short = order.shortItems;
    final extra = order.extraItems;

    if (order.allFulfilled) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('All Items Fulfilled'),
          content: const Text(
            'All items received with no discrepancies. Ready to proceed to summary.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (proceed == true && mounted) {
        context.push(AppRoutes.receivingSummary);
      }
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => _ProceedWarningDialog(short: short, extra: extra),
    );
    if (proceed == true && mounted) {
      context.push(AppRoutes.receivingSummary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(activeReceiveNotifierProvider);
    if (order == null) {
      return const Scaffold(
          body: Center(child: Text('No active receive session')));
    }

    final items = order.lineItems;
    final fulfilled = items
        .where(
            (i) => !i.flagged && i.received == i.expected && i.received != null)
        .length;
    final short = order.shortItems.length;
    final extra = order.extraItems.length;
    final remaining =
        items.where((i) => i.received == null && !i.flagged).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.id,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              order.supplier,
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${items.length} items',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  child: MobileScanner(
                    controller: _scanner,
                    onDetect: _onDetect,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: FilledButton.tonalIcon(
                    onPressed: _showManualEntryDialog,
                    icon: const Icon(Icons.keyboard, size: 14),
                    label: const Text('Manual'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      textStyle: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  _StatCell(
                      label: 'Fulfilled',
                      value: fulfilled,
                      color: AppColors.success),
                  _StatCell(
                      label: 'Short', value: short, color: AppColors.warning),
                  _StatCell(
                      label: 'Extra', value: extra, color: AppColors.error),
                  _StatCell(label: 'Remaining', value: remaining, color: null),
                ],
              ),
            ),
            const _TableHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _ItemRow(
                    index: index + 1,
                    item: item,
                    onFlag: () => _showFlagDialog(item),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: ElevatedButton(
                onPressed: () => _onProceed(order),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTextStyles.title.copyWith(
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.onBackground,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.subtitle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'ITEM',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.subtitle,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              'PO',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.subtitle,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              'RCVD',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.subtitle,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              'DIFF',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.subtitle,
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final int index;
  final PoLineItem item;
  final VoidCallback onFlag;

  const _ItemRow({
    required this.index,
    required this.item,
    required this.onFlag,
  });

  Color? get _rowColor {
    if (item.flagged || item.received == null) return null;
    if (item.received! < item.expected) return const Color(0xFFFFF8E1);
    if (item.received! > item.expected) return const Color(0xFFFFEBEE);
    return const Color(0xFFE8F5E9);
  }

  @override
  Widget build(BuildContext context) {
    final received = item.received ?? 0;
    final diff = received - item.expected;
    Color receivedColor = AppColors.onBackground;
    if (!item.flagged && item.received != null) {
      if (received < item.expected) receivedColor = AppColors.warning;
      if (received > item.expected) receivedColor = AppColors.error;
      if (received == item.expected) receivedColor = AppColors.success;
    }

    return Container(
      color: _rowColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$index',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.subtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onBackground,
                  ),
                ),
                Text(
                  item.itemCode,
                  style:
                      AppTextStyles.micro.copyWith(color: AppColors.subtitle),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${item.expected}',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              item.received != null ? '$received' : '—',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: receivedColor,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              item.received == null
                  ? '—'
                  : diff == 0
                      ? '—'
                      : diff > 0
                          ? '+$diff'
                          : '$diff',
              textAlign: TextAlign.center,
              style: AppTextStyles.micro.copyWith(
                fontWeight: FontWeight.w700,
                color: diff > 0
                    ? AppColors.error
                    : diff < 0
                        ? AppColors.warning
                        : AppColors.subtitle,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.flag_outlined,
                size: 16,
                color: item.flagged
                    ? AppColors.error
                    : AppColors.subtitle.withValues(alpha: 0.4),
              ),
              onPressed: onFlag,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProceedWarningDialog extends StatefulWidget {
  final List<PoLineItem> short;
  final List<PoLineItem> extra;

  const _ProceedWarningDialog({
    required this.short,
    required this.extra,
  });

  @override
  State<_ProceedWarningDialog> createState() => _ProceedWarningDialogState();
}

class _ProceedWarningDialogState extends State<_ProceedWarningDialog> {
  bool _shortExpanded = true;
  bool _extraExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review Before Proceeding'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Some items have discrepancies. Go back to rescan, or proceed to summary.',
              style: AppTextStyles.caption.copyWith(color: AppColors.subtitle),
            ),
            const SizedBox(height: 10),
            if (widget.short.isNotEmpty) ...[
              _IssueSection(
                label: 'Items Unfulfilled',
                color: AppColors.warning,
                count: widget.short.length,
                expanded: _shortExpanded,
                onToggle: () =>
                    setState(() => _shortExpanded = !_shortExpanded),
                items: widget.short,
                qtyColor: AppColors.warning,
              ),
              const SizedBox(height: 8),
            ],
            if (widget.extra.isNotEmpty)
              _IssueSection(
                label: 'Extra Items',
                color: AppColors.error,
                count: widget.extra.length,
                expanded: _extraExpanded,
                onToggle: () =>
                    setState(() => _extraExpanded = !_extraExpanded),
                items: widget.extra,
                qtyColor: AppColors.error,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Back'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Proceed Anyway'),
        ),
      ],
    );
  }
}

class _IssueSection extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;
  final List<PoLineItem> items;
  final Color qtyColor;

  const _IssueSection({
    required this.label,
    required this.color,
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.items,
    required this.qtyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style:
                      AppTextStyles.micro.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 14,
                color: AppColors.subtitle,
              ),
            ],
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.only(left: 6),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.border, width: 2),
              ),
            ),
            child: Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.fromLTRB(6, 3, 0, 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${item.received ?? 0}/${item.expected}',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: qtyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}
