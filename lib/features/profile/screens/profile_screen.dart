import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).valueOrNull;
    final settings = ref.watch(profileSettingsProvider);
    final notifier = ref.read(profileSettingsProvider.notifier);

    if (session == null) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final initials = session.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Green header with avatar
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 28),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  child: Text(
                    initials,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  session.name,
                  style:
                      AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  session.role.name[0].toUpperCase() +
                      session.role.name.substring(1),
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Profile Information section
          _SectionHeader(label: 'Profile Information', brightness: brightness),
          _InfoTile(
            label: 'Email',
            value: session.email,
            icon: Icons.email_outlined,
          ),
          _InfoTile(
            label: 'Site',
            value: session.site,
            icon: Icons.warehouse_outlined,
          ),

          // Preferences section
          _SectionHeader(label: 'Preferences', brightness: brightness),

          SwitchListTile(
            value: settings.biometricEnabled,
            onChanged: (_) => notifier.toggleBiometric(),
            title: Text('Biometric login', style: AppTextStyles.bodyMedium),
            secondary: const Icon(Icons.fingerprint),
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            value: settings.darkModeEnabled,
            onChanged: (_) => notifier.toggleDarkMode(),
            title: Text('Dark mode', style: AppTextStyles.bodyMedium),
            secondary: const Icon(Icons.dark_mode_outlined),
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: (_) => notifier.toggleNotifications(),
            title: Text('Push notifications', style: AppTextStyles.bodyMedium),
            secondary: const Icon(Icons.notifications_outlined),
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            value: settings.hapticFeedbackEnabled,
            onChanged: (_) => notifier.toggleHapticFeedback(),
            title: Text('Haptic feedback', style: AppTextStyles.bodyMedium),
            secondary: const Icon(Icons.vibration_outlined),
            activeThumbColor: AppColors.primary,
          ),

          const SizedBox(height: 24),

          // Sign out
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                foregroundColor: AppColors.error,
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              child: Text(
                'Sign Out',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Brightness brightness;

  const _SectionHeader({required this.label, required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.micro.copyWith(
          color: AppColors.textSecondary(brightness),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(brightness),
          )),
      subtitle: Text(value, style: AppTextStyles.bodyMedium),
    );
  }
}
