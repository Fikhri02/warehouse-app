import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

class OrderStatusBar extends StatelessWidget {
  final OrderStatus status;
  final int itemCount;

  const OrderStatusBar({
    super.key,
    required this.status,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$itemCount ITEMS',
            style: AppTextStyles.micro.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Text(
            status.displayName.toUpperCase(),
            style: AppTextStyles.micro.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
