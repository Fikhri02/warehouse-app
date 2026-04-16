import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;

  const AlertCard({super.key, required this.alert});

  IconData _iconFor(AlertType type) {
    return switch (type) {
      AlertType.lowStock => Icons.inventory_2_outlined,
      AlertType.taskAssigned => Icons.assignment_outlined,
      AlertType.discrepancy => Icons.warning_amber_outlined,
      AlertType.taskCompleted => Icons.check_circle_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final secondaryText = AppColors.textSecondary(brightness);
    final unreadBg = isDark ? const Color(0xFF1C2B29) : Colors.white;
    final readBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final titleStyle = alert.isRead
        ? AppTextStyles.bodyMedium.copyWith(color: secondaryText)
        : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600);
    final bodyStyle = AppTextStyles.bodySmall.copyWith(
      color: alert.isRead ? secondaryText : null,
    );

    return Card(
      color: alert.isRead ? readBg : unreadBg,
      elevation: alert.isRead ? 0 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconFor(alert.type),
              color: alert.isRead ? secondaryText : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(alert.body, style: bodyStyle),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(alert.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!alert.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.unread,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
