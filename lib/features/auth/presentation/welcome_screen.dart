import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text('WareTrack',
                    style: AppTextStyles.display.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('Warehouse Management',
                    style:
                        AppTextStyles.caption.copyWith(color: Colors.white60)),
                const SizedBox(height: 14),
                Text(
                  'Fast stock operations for every shift.',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.surfaceFor(brightness),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Move inventory with fewer taps.',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Count stock, receive purchase orders, and keep the warehouse in sync from one app.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use your warehouse account to continue.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
