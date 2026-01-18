import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/counter.dart';
import '../../../widgets/large_area_button.dart';
import '../../../widgets/widget_extensions.dart';

/// 보조 카운터 (동적)
/// - 인라인 +/- 버튼으로 조작
/// - 롱프레스: 인라인 편집기 열기
/// - 목표 달성 시: 펄스 애니메이션, 햅틱 피드백, 체크마크 배지
class SecondaryCounter extends StatefulWidget {
  final int id;
  final int value;
  final String label;
  final SecondaryCounterType type;
  final int? targetValue;
  final int? resetAt;
  final bool isLinked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  /// 롱프레스 콜백 - 위젯의 Rect 정보를 함께 전달
  final void Function(Rect sourceRect) onLongPress;
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

  @override
  State<SecondaryCounter> createState() => _SecondaryCounterState();
}

class _SecondaryCounterState extends State<SecondaryCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _wasCompleted = false;

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    final target = widget.targetValue ?? widget.resetAt;
    if (target == null || target == 0) return 0.0;
    return (widget.value / target).clamp(0.0, 1.0);
  }

  /// 목표/리셋 값
  int? get displayTarget => widget.targetValue ?? widget.resetAt;

  /// 목표 달성 여부 (goal 타입만)
  bool get isCompleted {
    if (widget.type == SecondaryCounterType.goal && widget.targetValue != null) {
      return widget.value >= widget.targetValue!;
    }
    return false;
  }

  /// 타입에 따른 아이콘
  IconData get typeIcon {
    return widget.type == SecondaryCounterType.goal ? Icons.flag : Icons.refresh;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _wasCompleted = isCompleted;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SecondaryCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 목표 달성 상태가 변경되었을 때
    final nowCompleted = isCompleted;
    if (nowCompleted && !_wasCompleted) {
      _triggerCompletionEffect();
    }
    _wasCompleted = nowCompleted;
  }

  void _triggerCompletionEffect() {
    // 펄스 애니메이션 (2초간 반복 후 정지)
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _pulseController.stop();
        _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 200));
      }
    });

    // 더블 탭 패턴 햅틱 피드백
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTarget = displayTarget != null;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return GestureDetector(
      onLongPress: () => widget.onLongPress(context.getWidgetRect()),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = isCompleted ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale.clamp(1.0, 1.15),
            child: child,
          );
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? successColor
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
                                widget.label,
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
                            if (widget.onLinkToggle != null)
                              GestureDetector(
                                onTap: widget.onLinkToggle,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    widget.isLinked ? Icons.link : Icons.link_off,
                                    size: 16,
                                    color: widget.isLinked
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
                                isCompleted ? successColor : AppColors.primary,
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
                                key: ValueKey(widget.value),
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${widget.value}',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: isCompleted
                                          ? successColor
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
                                            ? successColor
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
                            onPressed: widget.value > 0 ? widget.onDecrement : null,
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
                            onPressed: widget.onIncrement,
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

            // 완료 시 체크마크 배지 (우상단)
            if (isCompleted)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: successColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: successColor.withAlpha(100),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
