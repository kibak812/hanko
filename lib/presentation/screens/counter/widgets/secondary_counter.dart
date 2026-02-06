import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/counter.dart';
import '../../../widgets/large_area_button.dart';
import '../../../widgets/widget_extensions.dart';

/// 보조 카운터 (동적)
/// - 인라인 +/- 버튼으로 조작
/// - 롱프레스: 인라인 편집기 열기
/// - 목표 달성 시: Glow 애니메이션, 햅틱 피드백
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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  bool _wasCompleted = false;
  int _previousValue = 0;
  bool _isFlashing = false;
  bool _showResetValue = false; // 리셋 중 최대값 표시 여부

  /// 표시할 값 (리셋 중에는 resetAt 값 표시)
  int get displayValue {
    if (_showResetValue && widget.resetAt != null) {
      return widget.resetAt!;
    }
    return widget.value;
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    final target = widget.targetValue ?? widget.resetAt;
    if (target == null || target == 0) return 0.0;
    // 리셋 중에는 100% 표시
    if (_showResetValue) return 1.0;
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

  /// primary 색상 강조 여부 (goal 완료 또는 repetition 리셋 중)
  bool get isHighlighted => isCompleted || _showResetValue;

  /// 타입에 따른 아이콘
  IconData get typeIcon {
    return widget.type == SecondaryCounterType.goal ? Icons.flag : Icons.refresh;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
    _wasCompleted = isCompleted;
    _previousValue = widget.value;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SecondaryCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 목표 달성 상태가 변경되었을 때 (goal 타입)
    final nowCompleted = isCompleted;
    if (nowCompleted && !_wasCompleted) {
      _triggerCompletionEffect();
    }
    _wasCompleted = nowCompleted;

    // 리셋 감지 (repetition 타입: 값이 resetAt-1에서 0으로 변경됨)
    // 예: resetAt=5이면 4->0 변화 시 트리거
    if (widget.type == SecondaryCounterType.repetition &&
        widget.resetAt != null &&
        _previousValue == widget.resetAt! - 1 &&
        widget.value == 0) {
      _triggerResetEffect();
    }
    _previousValue = widget.value;
  }

  void _triggerCompletionEffect() {
    // Glow 애니메이션 (2회 반복 후 부드럽게 페이드아웃)
    _pulseController.repeat(reverse: true);

    // 800ms * 4 = 3.2초 (0→1→0→1→0 = 2회 완전 사이클)
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        _pulseController.stop();
        _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 600));
      }
    });

    // 햅틱 피드백
    HapticFeedback.mediumImpact();
  }

  void _triggerResetEffect() {
    // 리셋 값(5/5) 표시 + 파란색 플래시
    setState(() {
      _isFlashing = true;
      _showResetValue = true;
    });

    // 플래시: 밝아짐 → 잠시 유지 → 꺼짐 → 0으로 변경
    _flashController.forward(from: 0.0).then((_) {
      if (mounted) {
        // 잠시 유지 후 reverse
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _flashController.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _isFlashing = false;
                  _showResetValue = false; // 이제 실제 값(0) 표시
                });
              }
            });
          }
        });
      }
    });

    // 햅틱 피드백
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final hasTarget = displayTarget != null;
    final textSecondary = context.textSecondary;

    return GestureDetector(
      onLongPress: () => widget.onLongPress(context.getWidgetRect()),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _flashAnimation]),
        builder: (context, child) {
          final glowIntensity = isCompleted ? _pulseAnimation.value : 0.0;
          final flashIntensity = _isFlashing ? _flashAnimation.value : 0.0;

          // glow (목표 달성) 또는 flash (리셋) 효과 - 둘 다 primary 색상
          List<BoxShadow>? shadows;
          final effectIntensity = glowIntensity > 0 ? glowIntensity : flashIntensity;
          if (effectIntensity > 0) {
            shadows = [
              BoxShadow(
                color: AppColors.primary.withAlpha((180 * effectIntensity).toInt()),
                blurRadius: 24 * effectIntensity,
                spreadRadius: 4 * effectIntensity,
              ),
            ];
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: shadows,
            ),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? AppColors.primary
                  : context.border,
              width: isHighlighted ? 2 : 1,
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
                          backgroundColor: context.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
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
                            key: ValueKey(displayValue),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$displayValue',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: isHighlighted
                                      ? AppColors.primary
                                      : context.textPrimary,
                                ),
                              ),
                              if (hasTarget) ...[
                                const SizedBox(width: 2),
                                Text(
                                  '/$displayTarget',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isHighlighted
                                        ? AppColors.primary
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
                color: context.border,
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
                      color: context.border,
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
      ),
    );
  }
}
