import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/qty_adjuster.dart';
import '../providers/stock_count_provider.dart';
import '../../../core/models/count_session.dart';

class ScanCountScreen extends ConsumerStatefulWidget {
  const ScanCountScreen({super.key});

  @override
  ConsumerState<ScanCountScreen> createState() => _ScanCountScreenState();
}

class _ScanCountScreenState extends ConsumerState<ScanCountScreen> {
  final MobileScannerController _scanner = MobileScannerController();
  ({String code, String name})? _scanned;
  int _qty = 0;
  bool _scanning = true;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Item not found — try again or enter manually')),
        );
        setState(() => _scanning = true);
        return;
      }
      setState(() {
        _scanned = (code: code, name: name);
        _qty = 0;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error looking up item — please try again')),
      );
      setState(() => _scanning = true);
    }
  }

  void _confirmItem() {
    final item = _scanned;
    if (item == null) return;
    ref.read(stockCountNotifierProvider.notifier).addItem(
          CountItem(
            itemCode: item.code,
            itemName: item.name,
            expected: 0,
            counted: _qty,
          ),
        );
    setState(() {
      _scanned = null;
      _qty = 0;
      _scanning = true;
    });
  }

  void _skipItem() {
    setState(() {
      _scanned = null;
      _qty = 0;
      _scanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(stockCountNotifierProvider);
    final itemCount = session?.items.length ?? 0;
    final location = session?.location ?? '';
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(location.isEmpty ? 'Scan Items' : location),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('$itemCount counted',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70)),
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
              child: _scanning
                  ? MobileScanner(
                      controller: _scanner,
                      onDetect: _onDetect,
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.qr_code_scanner,
                            color: Colors.white38, size: 48),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _scanned == null
                    ? Center(
                        child: Text(
                          'Point camera at barcode',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary(brightness),
                          ),
                        ),
                      )
                    : Column(
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
                                      color: AppColors.textSecondary(
                                        brightness,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_scanned!.name,
                                      style: AppTextStyles.title),
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
                                  onPressed: _skipItem,
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
                        ],
                      ),
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton(
                onPressed: itemCount > 0
                    ? () => context.push(AppRoutes.stockCountReview)
                    : null,
                child: const Text('Finish Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
