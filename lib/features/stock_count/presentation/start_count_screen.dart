import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/stock_count_provider.dart';

class StartCountScreen extends ConsumerStatefulWidget {
  const StartCountScreen({super.key});

  @override
  ConsumerState<StartCountScreen> createState() => _StartCountScreenState();
}

class _StartCountScreenState extends ConsumerState<StartCountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(stockCountNotifierProvider.notifier).tryResumeSession(),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(stockCountNotifierProvider.notifier).startSession(
          location: _locationController.text.trim(),
          label: _labelController.text.trim().isEmpty
              ? null
              : _labelController.text.trim(),
        );
    if (mounted) context.push(AppRoutes.stockCountScan);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final activeSession = ref.watch(stockCountNotifierProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('New Count Session')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (activeSession != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningSurface(brightness),
                      border: Border.all(
                        color: AppColors.warningBorder(brightness),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Resume in-progress session',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warningForeground(brightness),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeSession.label == null
                              ? activeSession.location
                              : '${activeSession.location} · ${activeSession.label}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warningForeground(brightness),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () =>
                              context.push(AppRoutes.stockCountScan),
                          child: Text(
                            activeSession.items.isEmpty
                                ? 'Resume Session'
                                : 'Resume ${activeSession.items.length} Counted Items',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const _FieldLabel('Location / Zone'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter a location' : null,
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Reference (optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Monthly cycle count',
                  ),
                ),
                if (!isOnline) ...[
                  const SizedBox(height: 16),
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
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.warningForeground(brightness),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No connection — session will be saved locally and synced when online.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warningForeground(brightness),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _start,
                  child: const Text('Start Session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.micro.copyWith(
          color: AppColors.textSecondary(Theme.of(context).brightness),
          letterSpacing: 0.5,
        ),
      );
}
