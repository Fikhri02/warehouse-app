import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/order_status_bar.dart';

class DeliveryOrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback onTap;

  const DeliveryOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.orderNumber,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textPrimary(brightness),
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(order.deliveryDate),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.fromLocation.name} → ${order.toLocation.name}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                ],
              ),
            ),
            OrderStatusBar(status: order.status, itemCount: order.items.length),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
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
