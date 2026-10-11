import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';

/// Server mode: a count is where you count, plus an optional label for the reviewer.
class CountSetupScreen extends ConsumerStatefulWidget {
  const CountSetupScreen({super.key});

  @override
  ConsumerState<CountSetupScreen> createState() => _CountSetupScreenState();
}

class _CountSetupScreenState extends ConsumerState<CountSetupScreen> {
  final _label = TextEditingController();
  String? _locationId;
  bool _submitted = false;
  bool _starting = false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _submitted = true);
    final locations = ref.read(countLocationsProvider).valueOrNull ?? const [];
    final chosen = locations.where((l) => l.id == _locationId);
    if (chosen.isEmpty || _starting) return;
    setState(() => _starting = true);
    final label = _label.text.trim();
    await ref.read(stockCountNotifierProvider.notifier).startSession(
          location: chosen.first.code,
          label: label.isEmpty ? null : label,
          locationId: chosen.first.id,
        );
    if (mounted) context.pushReplacement(AppRoutes.stockCountScan);
  }

  Future<void> _refresh() async {
    await ref.read(syncCoordinatorProvider).syncNow();
    ref.invalidate(countLocationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final locations = ref.watch(countLocationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Count Session')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Choose where you are counting. Everything you scan in this session is counted there.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
              ),
              const SizedBox(height: 16),
              locations.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text(
                  "Couldn't load the locations. Pull down to try again.",
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
                data: (items) => items.isEmpty
                    ? Text(
                        'No locations on this phone yet. Pull down to refresh, or ask a supervisor to add them.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _locationId,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          errorText: _submitted && _locationId == null ? 'Choose where you are counting.' : null,
                        ),
                        items: [
                          for (final l in items) DropdownMenuItem(value: l.id, child: Text('${l.code} · ${l.kind}')),
                        ],
                        onChanged: (value) => setState(() => _locationId = value),
                      ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _label,
                maxLength: 120,
                decoration: const InputDecoration(labelText: 'Label (optional)', hintText: 'For example: Aisle A, front racks'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _starting ? null : _start,
                child: const Text('Start Counting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
