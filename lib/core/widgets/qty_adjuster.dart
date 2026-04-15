import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class QtyAdjuster extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const QtyAdjuster({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AdjustButton(
          icon: Icons.remove,
          onTap: value > 0 ? () => onChanged(value - 1) : null,
        ),
        Expanded(
          child: Center(
            child: Text(
              '$value',
              style: AppTextStyles.display.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _AdjustButton(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _AdjustButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? AppColors.border : AppColors.onBackground,
        ),
      ),
    );
  }
}
