import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 메인 카운터 숫자 표시 위젯
/// 96px 거대한 숫자로 3m 거리에서도 읽기 가능
/// 인라인 +/- 버튼으로 조작
class CounterDisplay extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterDisplay({
    super.key,
    required this.value,
    required this.label,
    required this.onIncrement,
    required this.onDecrement,
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
          // 인라인 +/- 버튼과 숫자
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // - 버튼
              _MainCounterButton(
                icon: Icons.remove,
                onPressed: value > 0 ? onDecrement : null,
                isDark: isDark,
              ),
              const SizedBox(width: 16),

              // 숫자
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
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
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),
              // + 버튼
              _MainCounterButton(
                icon: Icons.add,
                onPressed: onIncrement,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 메인 카운터용 +/- 버튼
class _MainCounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;

  const _MainCounterButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
            .withAlpha(77);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.backgroundDark
              : AppColors.border.withAlpha(128),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
