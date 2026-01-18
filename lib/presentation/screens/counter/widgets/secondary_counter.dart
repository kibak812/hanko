import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 보조 카운터 (코, 패턴 반복)
class SecondaryCounter extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  const SecondaryCounter({
    super.key,
    required this.value,
    required this.label,
    required this.onIncrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onIncrement,
      onLongPress: onReset,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '$value',
                key: ValueKey(value),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '꾹 눌러 리셋',
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.6)
                    : AppColors.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
