import 'package:flutter/material.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/widgets/atura_logo.dart';
import 'package:warehouse_app/features/alerts/widgets/alerts_bell.dart';

/// The home header: the Atura wordmark and the alerts bell, on the theme's header. The logo is deep teal on the
/// light-mode header and active mint on the dark one, as the brand palette pairs them.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      centerTitle: false,
      title: AturaWordmark(height: 22, color: isDark ? AppColors.darkAccent : AppColors.primary),
      actions: const [AlertsBell()],
    );
  }
}
