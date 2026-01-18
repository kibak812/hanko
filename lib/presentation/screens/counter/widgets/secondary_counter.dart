import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/counter.dart';
import '../../../widgets/large_area_button.dart';

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
  final bool isLinked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongPress;
  final VoidCallback? onLinkToggle;

  const SecondaryCounter({
    super.key,
    required this.id,
    required this.value,
    required this.label,
    required this.type,
    this.targetValue,
    this.resetAt,
    this.isLinked = false,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongPress,
    this.onLinkToggle,
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

  /// 타입에 따른 아이콘
  IconData get typeIcon {
    return type == SecondaryCounterType.goal ? Icons.flag : Icons.refresh;
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
                  // 라벨 (좌상단) + 연동 아이콘 (우상단)
                  Row(
                    children: [
                      // 타입 아이콘 + 라벨
                      Icon(
                        typeIcon,
                        size: 12,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 4),
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
                      // 연동 아이콘 (우상단)
                      if (onLinkToggle != null)
                        GestureDetector(
                          onTap: onLinkToggle,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isLinked ? Icons.link : Icons.link_off,
                              size: 16,
                              color: isLinked
                                  ? AppColors.primary
                                  : textSecondary.withAlpha(120),
                            ),
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

                  // 숫자 (중앙) + 목표값 (우측 하단)
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Row(
                          key: ValueKey(value),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$value',
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
                            if (hasTarget) ...[
                              const SizedBox(width: 2),
                              Text(
                                '/$displayTarget',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isCompleted
                                      ? AppColors.success
                                      : textSecondary.withAlpha(150),
                                ),
                              ),
                            ],
                          ],
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
                    child: LargeAreaButton(
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
                    child: LargeAreaButton(
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
