import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

/// "Good morning" 5:00–11:59, "Good afternoon" 12:00–17:59, "Good evening" the rest — night shifts included.
String greetingFor(DateTime t) {
  if (t.hour >= 5 && t.hour < 12) return 'Good morning';
  if (t.hour >= 12 && t.hour < 18) return 'Good afternoon';
  return 'Good evening';
}

/// "Good morning, John" and "Worker · Warehouse A", at the top of the home content. Sign in shows this same widget,
/// larger, as its greeting and glides it into this spot.
class DashboardGreeting extends StatelessWidget {
  final UserSession? session;

  /// Where the greeting reads the time from; tests pass a fixed clock.
  final DateTime Function() clock;
  const DashboardGreeting({super.key, required this.session, this.clock = DateTime.now});

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
        Text('${greetingFor(clock())}, $firstName',
            style: AppTextStyles.display
                .copyWith(color: AppColors.textPrimary(brightness), fontSize: 24, height: 1.2)),
        const SizedBox(height: 4),
        Text('$role · ${session?.site ?? ''}',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness), height: 1.3)),
      ],
    );
  }
}
