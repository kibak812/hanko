import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 메인 카운터 숫자 표시 위젯
/// 96px 거대한 숫자로 3m 거리에서도 읽기 가능
class CounterDisplay extends StatelessWidget {
  final int value;
  final String label;

  const CounterDisplay({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 24,
                ),
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.04),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              '$value',
              key: ValueKey(value),
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
