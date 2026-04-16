import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/receiving_provider.dart';

class ReceiveSummaryScreen extends ConsumerStatefulWidget {
  const ReceiveSummaryScreen({super.key});

  @override
  ConsumerState<ReceiveSummaryScreen> createState() =>
      _ReceiveSummaryScreenState();
}

class _ReceiveSummaryScreenState extends ConsumerState<ReceiveSummaryScreen> {
  Uint8List? _signatureBytes;

  Future<void> _openSignaturePad() async {
    final bytes = await context.push<Uint8List>(AppRoutes.receivingSignature);
    if (!mounted) return;
    if (bytes != null) {
      setState(() => _signatureBytes = bytes);
    }
  }

  Future<void> _submit() async {
    final notifier = ref.read(activeReceiveNotifierProvider.notifier);
    try {
      await notifier.submitReceive(signature: _signatureBytes);
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      debugPrint('submitReceive failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit — please try again'),
          ),
        );
      }
    }
  }

  Future<void> _onClosePOTapped() async {
    final action = await showDialog<_SignAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign this PO?'),
        content: const Text('Add your signature before submitting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_SignAction.skip),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_SignAction.sign),
            child: const Text('Sign'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (action == null) {
      // Dialog dismissed without choosing — do nothing
      return;
    }

    if (action == _SignAction.skip) {
      await _submit();
      return;
    }

    // action == _SignAction.sign
    await _openSignaturePad();
    // After returning from the pad, the user sees the preview + Submit PO button.
    // They tap "Submit PO" explicitly (no auto-submit here).
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(activeReceiveNotifierProvider);
    final brightness = Theme.of(context).brightness;

    if (order == null) {
      return const Scaffold(body: Center(child: Text('No active session')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${order.id} — Summary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'All items processed',
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
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Column(
                      children: order.lineItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final received = item.received ?? 0;
                        final ok = !item.flagged && received == item.expected;
                        final variance = received - item.expected;
                        final color = item.flagged || received != item.expected
                            ? AppColors.error
                            : AppColors.success;

                        return Column(
                          children: [
                            if (idx > 0) const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.itemName,
                                            style: AppTextStyles.body.copyWith(
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text('Expected ${item.expected}',
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: AppColors.textSecondary(
                                                brightness,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$received',
                                            style: AppTextStyles.title
                                                .copyWith(color: color),
                                          ),
                                          if (ok) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                                Icons.check_circle_outline,
                                                size: 14,
                                                color: AppColors.success),
                                          ],
                                        ],
                                      ),
                                      if (item.flagged)
                                        Text('flagged',
                                            style: AppTextStyles.micro
                                                .copyWith(color: color)),
                                      if (!item.flagged &&
                                          received != item.expected)
                                        Text(
                                            variance >= 0
                                                ? '+$variance'
                                                : '$variance',
                                            style: AppTextStyles.micro
                                                .copyWith(color: color)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  if (order.hasFlagged) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface(brightness),
                        border: Border.all(
                          color: AppColors.warningBorder(brightness),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 16,
                            color: AppColors.warningForeground(brightness),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Discrepancy noted. Supervisor will be notified on submit.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warningForeground(brightness),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_signatureBytes != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Signature',
                              style: AppTextStyles.body
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.memory(
                                _signatureBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _openSignaturePad,
                                child: const Text('Re-sign'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_signatureBytes != null) ...[
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit PO'),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: _onClosePOTapped,
                      child: const Text('Close PO & Submit'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SignAction { sign, skip }
