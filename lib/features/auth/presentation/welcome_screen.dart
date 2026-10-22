import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/branding/welcome_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Inventory.',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Seamless ',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'warehouse',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.softMint,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'management.',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Track, organize, and move inventory\nwith speed and accuracy - all in one\npowerful app.',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              // Always on a dark teal backdrop: the light-mode teal button vanishes here.
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkAccent,
                                foregroundColor: AppColors.onDarkAccent,
                              ),
                              onPressed: () => context.push(AppRoutes.login),
                              child: const Text('Get Started'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Use your warehouse account to continue.',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
