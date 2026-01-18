import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 보조 카운터 (코, 패턴 반복)
/// - 탭: +1 증가 (즉시 반응)
/// - 롱프레스: 설정 바텀시트 열기
class SecondaryCounter extends StatefulWidget {
  final int value;
  final String label;
  final int? targetValue;
  final int? resetAt;
  final VoidCallback onIncrement;
  final VoidCallback onLongPress;

  const SecondaryCounter({
    super.key,
    required this.value,
    required this.label,
    this.targetValue,
    this.resetAt,
    required this.onIncrement,
    required this.onLongPress,
  });

  @override
  State<SecondaryCounter> createState() => _SecondaryCounterState();
}

class _SecondaryCounterState extends State<SecondaryCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _flashAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    final target = widget.targetValue ?? widget.resetAt;
    if (target == null || target == 0) return 0.0;
    return (widget.value / target).clamp(0.0, 1.0);
  }

  /// 목표/리셋 값
  int? get displayTarget => widget.targetValue ?? widget.resetAt;

  /// 목표 달성 여부
  bool get isCompleted {
    if (widget.targetValue != null) {
      return widget.value >= widget.targetValue!;
    }
    return false;
  }

  void _onTapDown(TapDownDetails details) {
    _flashController.forward();
    // 즉시 증가 (터치 즉시 반응)
    widget.onIncrement();
  }

  void _onTapUp(TapUpDetails details) {
    _flashController.reverse();
  }

  void _onTapCancel() {
    _flashController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTarget = displayTarget != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _flashAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: hasTarget ? 110 : 100,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // 값 표시
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  '${widget.value}',
                  key: ValueKey(widget.value),
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? AppColors.success
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                  ),
                ),
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
                widget.label,
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
      ),
    );
  }
}
