import 'package:flutter/material.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

class QuickActionCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bg = isPrimary ? AppColors.primary : AppColors.surfaceFor(brightness);
    final fg = isPrimary ? Colors.white : AppColors.textPrimary(brightness);
    final sub =
        isPrimary ? Colors.white70 : AppColors.textSecondary(brightness);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isPrimary
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: fg, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: AppTextStyles.micro.copyWith(color: sub)),
            ],
          ],
        ),
      ),
    );
  }
}
