import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/purchase_order.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/receiving_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/count_records.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../data/repositories/receiving_repository.dart';

/// Where this receipt's goods are put away (server mode). Null: the default below.
final putAwayLocationProvider = StateProvider.autoDispose<String?>((_) => null);

/// Goods usually land at a dock first; without one, the first location.
String? defaultPutAway(List<CountLocation> locations) {
  for (final l in locations) {
    if (l.kind == 'Dock') return l.id;
  }
  return locations.isEmpty ? null : locations.first.id;
}

class _PutAwayPicker extends ConsumerWidget {
  const _PutAwayPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(putAwayLocationsProvider).valueOrNull ?? const <CountLocation>[];
    if (locations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('No locations on this phone yet. Pull down on the orders list to refresh.'),
      );
    }
    final chosen = ref.watch(putAwayLocationProvider) ?? defaultPutAway(locations);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
      child: DropdownButtonFormField<String>(
        initialValue: chosen,
        decoration: const InputDecoration(labelText: 'Put away in'),
        items: [for (final l in locations) DropdownMenuItem(value: l.id, child: Text('${l.code} · ${l.kind}'))],
        onChanged: (value) => ref.read(putAwayLocationProvider.notifier).state = value,
      ),
    );
  }
}

class ReceiveSummaryScreen extends ConsumerWidget {
  const ReceiveSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(activeReceiveNotifierProvider);
    if (order == null) {
      return const Scaffold(body: Center(child: Text('No active session')));
    }

    Future<void> onRescan() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Return to Scanning?'),
          content: const Text(
            'Going back will let you rescan items. Your current received quantities will be kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        context.pop();
      }
    }

    Future<void> onSignAndSubmit() async {
      final useApi = ref.read(useApiProvider);
      final locationId = useApi
          ? ref.read(putAwayLocationProvider) ?? defaultPutAway(ref.read(putAwayLocationsProvider).valueOrNull ?? const [])
          : null;
      if (useApi && locationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose where the goods are put away.')));
        return;
      }
      try {
        final bytes = await context.push<Uint8List?>(AppRoutes.receivingSignature);
        if (!context.mounted) return;
        await ref.read(activeReceiveNotifierProvider.notifier).submitReceive(signature: bytes, locationId: locationId);
        if (!context.mounted) return;
        if (useApi) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ref.read(isOnlineProvider) ? 'Receipt sent.' : "Receipt saved. It will be sent when you're back online."),
          ));
        }
        context.go(AppRoutes.receiving);
      } on StateError catch (error) {
        // Something the person can fix: more than is left, nothing new, no location.
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit — please try again')));
        }
        debugPrint('submitReceive failed: $error');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Summary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(16),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Review before signing',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _PoInfoCard(order: order),
                  const SizedBox(height: 6),
                  _StatsRow(order: order),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
                    child: Text(
                      'ITEMS',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.subtitle,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (ref.watch(useApiProvider)) const _PutAwayPicker(),
                  _ItemsTable(order: order),
                ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRescan,
                      child: const Text('Rescan'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onSignAndSubmit,
                      child: const Text('Sign & Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoInfoCard extends StatelessWidget {
  final PurchaseOrder order;

  const _PoInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    String dateLabel = '';
    if (order.dueDate != null) {
      final date = order.dueDate!;
      dateLabel = '${date.day} ${_month(date.month)} ${date.year}';
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    order.displayNumber,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  dateLabel,
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _InfoRow('Supplier', order.supplier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _month(int month) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month];
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.subtitle),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final PurchaseOrder order;

  const _StatsRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order.lineItems;
    final fulfilled = items
        .where(
            (i) => !i.flagged && i.received != null && i.received == i.expected)
        .length;
    final short = order.shortItems.length;
    final extra = order.extraItems.length;
    final flagged = items.where((i) => i.flagged).length;

    return Card(
      margin: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            _SummaryStatCell('Fulfilled', fulfilled, AppColors.success),
            _SummaryStatCell('Short', short, AppColors.warning),
            _SummaryStatCell('Extra', extra, AppColors.error),
            _SummaryStatCell('Flagged', flagged, AppColors.subtitle),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatCell extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryStatCell(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTextStyles.title.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
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

class _ItemsTable extends StatelessWidget {
  final PurchaseOrder order;

  const _ItemsTable({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
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
                  width: 30,
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
                  width: 30,
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
                  width: 30,
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
          ),
          const Divider(height: 1),
          ...order.lineItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final received = item.received ?? 0;
            final diff = received - item.expected;
            Color receivedColor = AppColors.onBackground;
            if (!item.flagged && item.received != null) {
              if (received < item.expected) receivedColor = AppColors.warning;
              if (received > item.expected) receivedColor = AppColors.error;
              if (received == item.expected) receivedColor = AppColors.success;
            }

            return Column(
              children: [
                if (index > 0) const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${index + 1}',
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
                              ),
                            ),
                            Text(
                              item.itemCode,
                              style: AppTextStyles.micro.copyWith(
                                color: AppColors.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${item.expected}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
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
                        width: 30,
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
                        child: Icon(
                          item.flagged ? Icons.flag : Icons.flag_outlined,
                          size: 14,
                          color: item.flagged
                              ? AppColors.error
                              : AppColors.subtitle.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
