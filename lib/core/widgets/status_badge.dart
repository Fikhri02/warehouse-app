import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum BadgeVariant { pending, received, done, inProgress }

class StatusBadge extends StatelessWidget {
  final BadgeVariant variant;

  const StatusBadge(this.variant, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (variant) {
      BadgeVariant.pending => ('PENDING', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      BadgeVariant.received => ('RECEIVED', const Color(0xFFE8F5E9), AppColors.success),
      BadgeVariant.done => ('DONE', const Color(0xFFE0F2F1), const Color(0xFF01483E)),
      BadgeVariant.inProgress => ('IN PROGRESS', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.micro.copyWith(color: fg)),
    );
  }
}
