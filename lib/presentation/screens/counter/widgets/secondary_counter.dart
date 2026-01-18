import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/counter.dart';

/// 보조 카운터 (동적)
/// - 인라인 +/- 버튼으로 조작
/// - 롱프레스: 설정 바텀시트 열기
class SecondaryCounter extends StatelessWidget {
  final int id;
  final int value;
  final String label;
  final SecondaryCounterType type;
  final int? targetValue;
  final int? resetAt;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongPress;

  const SecondaryCounter({
    super.key,
    required this.id,
    required this.value,
    required this.label,
    required this.type,
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

  /// 목표 달성 여부 (goal 타입만)
  bool get isCompleted {
    if (type == SecondaryCounterType.goal && targetValue != null) {
      return value >= targetValue!;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTarget = displayTarget != null;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.success
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 영역: 라벨 + 진행률 바 + 숫자
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 라벨 (좌상단)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // 목표값 표시 (있을 때만)
                      if (hasTarget)
                        Text(
                          '$value/$displayTarget',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isCompleted
                                ? AppColors.success
                                : textSecondary.withAlpha(150),
                          ),
                        ),
                    ],
                  ),

                  // 진행률 바 (목표가 있을 때만)
                  if (hasTarget) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor:
                            isDark ? AppColors.borderDark : AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // 숫자 (중앙)
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                ],
              ),
            ),

            // 구분선
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),

            // 하단 영역: -/+ 버튼 좌우 분할
            IntrinsicHeight(
              child: Row(
                children: [
                  // - 버튼 (왼쪽 절반)
                  Expanded(
                    child: _LargeAreaButton(
                      icon: Icons.remove,
                      onPressed: value > 0 ? onDecrement : null,
                      color: textSecondary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                  ),

                  // 세로 구분선
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),

                  // + 버튼 (오른쪽 절반)
                  Expanded(
                    child: _LargeAreaButton(
                      icon: Icons.add,
                      onPressed: onIncrement,
                      color: textSecondary,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 보조 카운터용 넓은 터치 영역 버튼
class _LargeAreaButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final BorderRadius borderRadius;

  const _LargeAreaButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? color.withAlpha(180) : color.withAlpha(77),
          ),
        ),
      ),
    );
  }
}
