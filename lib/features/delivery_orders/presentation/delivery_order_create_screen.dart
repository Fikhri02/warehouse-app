import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/item_picker_sheet.dart';
import 'package:warehouse_app/features/delivery_orders/providers/create_delivery_order_notifier.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class DeliveryOrderCreateScreen extends ConsumerStatefulWidget {
  final DeliveryOrder? editingOrder;

  const DeliveryOrderCreateScreen({
    super.key,
    this.editingOrder,
  });

  @override
  ConsumerState<DeliveryOrderCreateScreen> createState() =>
      _DeliveryOrderCreateScreenState();
}

class _DeliveryOrderCreateScreenState
    extends ConsumerState<DeliveryOrderCreateScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(createDeliveryOrderNotifierProvider);
      final editing = widget.editingOrder;
      if (editing != null) {
        ref
            .read(createDeliveryOrderNotifierProvider.notifier)
            .loadFromOrder(editing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createDeliveryOrderNotifierProvider);
    final locations = ref.watch(locationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editingOrder == null
              ? 'New Delivery Order'
              : 'Edit Delivery Order',
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StepIndicator(currentStep: _currentStep),
            const SizedBox(height: 16),
            Text(
              '* Required fields',
              style: AppTextStyles.caption.copyWith(color: AppColors.info),
            ),
            const SizedBox(height: 16),
            if (_currentStep == 0)
              _BasicInfoStep(
                state: state,
                locations: locations,
              ),
            if (_currentStep == 1)
              _ItemsStep(
                state: state,
                onChanged: (items) => ref
                    .read(createDeliveryOrderNotifierProvider.notifier)
                    .setItems(items),
              ),
            if (_currentStep == 2) _ReviewStep(state: state),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _buildActions(state),
        ),
      ),
    );
  }

  Widget _buildActions(CreateDeliveryOrderState state) {
    if (state.isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentStep == 0) {
      return ElevatedButton(
        onPressed: () {
          final valid = ref
              .read(createDeliveryOrderNotifierProvider.notifier)
              .validateStep1();
          if (valid) {
            setState(() => _currentStep = 1);
          }
        },
        child: const Text('Next: Add Items'),
      );
    }

    if (_currentStep == 1) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep = 0),
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final valid = ref
                    .read(createDeliveryOrderNotifierProvider.notifier)
                    .validateStep2();
                if (valid) {
                  setState(() => _currentStep = 2);
                }
              },
              child: const Text('Next: Review'),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _submit(asDraft: true),
                child: const Text('Save as Draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _submit(asDraft: false),
                child: const Text('Submit Order'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _currentStep = 1),
          child: const Text('Back to Items'),
        ),
      ],
    );
  }

  Future<void> _submit({required bool asDraft}) async {
    try {
      await ref
          .read(createDeliveryOrderNotifierProvider.notifier)
          .submit(asDraft: asDraft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save order: $error')),
      );
    }
  }
}

class _BasicInfoStep extends ConsumerWidget {
  final CreateDeliveryOrderState state;
  final AsyncValue<List<OrderLocation>> locations;

  const _BasicInfoStep({
    required this.state,
    required this.locations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return locations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Failed to load locations: $error'),
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RequiredLabel('From'),
            const SizedBox(height: 6),
            DropdownButtonFormField<OrderLocation>(
              initialValue: state.fromLocation,
              items: data
                  .map(
                    (location) => DropdownMenuItem(
                      value: location,
                      child: Text(location.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => ref
                  .read(createDeliveryOrderNotifierProvider.notifier)
                  .setFromLocation(value),
              decoration:
                  InputDecoration(errorText: state.errors['fromLocation']),
            ),
            const SizedBox(height: 16),
            const _RequiredLabel('To'),
            const SizedBox(height: 6),
            DropdownButtonFormField<OrderLocation>(
              initialValue: state.toLocation,
              items: data
                  .map(
                    (location) => DropdownMenuItem(
                      value: location,
                      child: Text(location.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => ref
                  .read(createDeliveryOrderNotifierProvider.notifier)
                  .setToLocation(value),
              decoration:
                  InputDecoration(errorText: state.errors['toLocation']),
            ),
            const SizedBox(height: 16),
            const _RequiredLabel('Delivery Date'),
            const SizedBox(height: 6),
            _DateField(
              value: state.deliveryDate,
              errorText: state.errors['deliveryDate'],
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: state.deliveryDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (selected != null) {
                  ref
                      .read(createDeliveryOrderNotifierProvider.notifier)
                      .setDate(selected);
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.requiresApproval,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => ref
                  .read(createDeliveryOrderNotifierProvider.notifier)
                  .toggleApproval(value),
              title: const Text('Require Approval'),
              subtitle: const Text('Supervisor must approve before packing'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: state.notes,
              minLines: 3,
              maxLines: 4,
              onChanged: (value) => ref
                  .read(createDeliveryOrderNotifierProvider.notifier)
                  .setNotes(value),
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ItemsStep extends StatelessWidget {
  final CreateDeliveryOrderState state;
  final ValueChanged<List<OrderItem>> onChanged;

  const _ItemsStep({
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.errors['items'] != null) ...[
          Text(
            state.errors['items']!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
        ],
        ItemPickerSheet(items: state.items, onChanged: onChanged),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final CreateDeliveryOrderState state;

  const _ReviewStep({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Summary', style: AppTextStyles.title),
                const SizedBox(height: 12),
                _ReviewRow('From', state.fromLocation?.name ?? '-'),
                _ReviewRow('To', state.toLocation?.name ?? '-'),
                _ReviewRow('Date', _formatDate(state.deliveryDate)),
                _ReviewRow(
                  'Approval',
                  state.requiresApproval ? 'Required' : 'Not required',
                ),
                _ReviewRow(
                  'Notes',
                  state.notes.trim().isEmpty ? '-' : state.notes.trim(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Items', style: AppTextStyles.title),
                const SizedBox(height: 10),
                for (final item in state.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ReviewRow(
                      item.itemName,
                      'SKU ${item.itemSku} · Qty ${item.quantity}',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isDone = index < currentStep;
        final isActive = index == currentStep;
        return Container(
          width: 28,
          height: 28,
          margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.success
                : isActive
                    ? AppColors.primary
                    : AppColors.border,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  '${index + 1}',
                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                ),
        );
      }),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String label;

  const _RequiredLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary(Theme.of(context).brightness),
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.info),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;

  const _DateField({
    required this.value,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(errorText: errorText),
        child: Row(
          children: [
            Expanded(
              child: Text(value == null ? 'Select a date' : _formatDate(value)),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary(brightness),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  const months = [
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
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
