import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 보조 카운터 (코, 패턴 반복)
/// - 인라인 +/- 버튼으로 조작
/// - 롱프레스: 설정 바텀시트 열기
class SecondaryCounter extends StatelessWidget {
  final int value;
  final String label;
  final int? targetValue;
  final int? resetAt;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongPress;

  const SecondaryCounter({
    super.key,
    required this.value,
    required this.label,
    this.targetValue,
    this.resetAt,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongPress,
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    final target = targetValue ?? resetAt;
    if (target == null || target == 0) return 0.0;
    return (value / target).clamp(0.0, 1.0);
  }

  /// 목표/리셋 값
  int? get displayTarget => targetValue ?? resetAt;

  /// 목표 달성 여부
  bool get isCompleted {
    if (targetValue != null) {
      return value >= targetValue!;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTarget = displayTarget != null;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        width: hasTarget ? 130 : 120,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? AppColors.success
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 진행률 바 (목표가 있을 때만)
            if (hasTarget) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor:
                      isDark ? AppColors.borderDark : AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 인라인 +/- 버튼과 값
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // - 버튼
                _InlineButton(
                  icon: Icons.remove,
                  onPressed: value > 0 ? onDecrement : null,
                  isDark: isDark,
                ),
                const SizedBox(width: 4),

                // 값 표시
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        '$value',
                        key: ValueKey(value),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppColors.success
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),
                // + 버튼
                _InlineButton(
                  icon: Icons.add,
                  onPressed: onIncrement,
                  isDark: isDark,
                ),
              ],
            ),

            // 목표값 표시 (있을 때만)
            if (hasTarget)
              Text(
                '/ $displayTarget',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),

            const SizedBox(height: 4),

            // 라벨
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 6),

            // 힌트
            Text(
              '꾹→설정',
              style: TextStyle(
                fontSize: 9,
                color: (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary)
                    .withAlpha(128),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 인라인 +/- 버튼
class _InlineButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;

  const _InlineButton({
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.backgroundDark
              : AppColors.border.withAlpha(128),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
