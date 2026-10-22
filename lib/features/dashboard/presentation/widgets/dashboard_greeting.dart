import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

/// "Good morning, John" and "Worker · Warehouse A", at the top of the home content.
class DashboardGreeting extends StatelessWidget {
  final UserSession? session;
  const DashboardGreeting({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final firstName = session?.name.split(' ').first ?? 'there';
    final role = switch (session?.role) {
      UserRole.supervisor => 'Supervisor',
      UserRole.worker => 'Worker',
      null => '',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good morning, $firstName',
            style: AppTextStyles.display
                .copyWith(color: AppColors.textPrimary(brightness), fontSize: 24, height: 1.2)),
        const SizedBox(height: 4),
        Text('$role · ${session?.site ?? ''}',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness), height: 1.3)),
      ],
    );
  }
}
