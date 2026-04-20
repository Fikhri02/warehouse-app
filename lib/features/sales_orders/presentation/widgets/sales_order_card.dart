import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/order_status_bar.dart';

class SalesOrderCard extends StatelessWidget {
  final SalesOrder order;
  final VoidCallback onTap;

  const SalesOrderCard({
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
                        _formatDate(order.orderDate),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.customerName,
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
