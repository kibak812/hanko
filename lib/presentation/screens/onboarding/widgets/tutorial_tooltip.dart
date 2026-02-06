import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 튜토리얼 말풍선 위치
enum TooltipPosition {
  top,
  bottom,
}

/// 튜토리얼 말풍선 UI
/// - 아이콘 + 제목 + 설명 + 버튼
/// - 대상 위치에 따라 위/아래 자동 배치
class TutorialTooltip extends StatefulWidget {
  final Rect? targetRect;
  final String title;
  final String description;
  final IconData? icon;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final int currentStep;
  final int totalSteps;
  final TooltipPosition? forcePosition;

  const TutorialTooltip({
    super.key,
    this.targetRect,
    required this.title,
    required this.description,
    this.icon,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.currentStep = 0,
    this.totalSteps = 4,
    this.forcePosition,
  });

  @override
  State<TutorialTooltip> createState() => _TutorialTooltipState();
}

class _TutorialTooltipState extends State<TutorialTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  TooltipPosition _calculatePosition(BuildContext context) {
    if (widget.forcePosition != null) return widget.forcePosition!;
    if (widget.targetRect == null) return TooltipPosition.bottom;

    final screenHeight = MediaQuery.of(context).size.height;
    final targetCenter = widget.targetRect!.center.dy;

    // 화면 상단 절반에 타겟이 있으면 아래에, 아니면 위에 배치
    return targetCenter < screenHeight / 2
        ? TooltipPosition.bottom
        : TooltipPosition.top;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final safeAreaPadding = MediaQuery.of(context).padding;
    final position = _calculatePosition(context);

    // 툴팁 예상 높이 (아이콘 + 텍스트 + 버튼)
    const tooltipHeight = 220.0;
    final minTop = safeAreaPadding.top + 16;
    final maxTop = screenSize.height - tooltipHeight - safeAreaPadding.bottom - 16;

    // 툴팁 위치 계산
    double top;
    if (widget.targetRect != null) {
      if (position == TooltipPosition.bottom) {
        top = widget.targetRect!.bottom + 16;
        // 화면 아래로 넘어가면 위로 배치
        if (top + tooltipHeight > screenSize.height - safeAreaPadding.bottom - 16) {
          top = widget.targetRect!.top - tooltipHeight - 16;
        }
      } else {
        top = widget.targetRect!.top - tooltipHeight - 16;
      }
      // 화면 경계 체크
      top = top.clamp(minTop, maxTop);
    } else {
      // 타겟이 없으면 화면 중앙
      top = (screenSize.height - tooltipHeight) / 2;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideOffset = position == TooltipPosition.bottom
            ? _slideAnimation.value
            : -_slideAnimation.value;

        return Positioned(
          left: 24,
          right: 24,
          top: top + slideOffset,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildTooltipCard(isDark),
          ),
        );
      },
    );
  }

  Widget _buildTooltipCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 스텝 인디케이터
          if (widget.totalSteps > 0) ...[
            _buildStepIndicator(isDark),
            const SizedBox(height: 16),
          ],

          // 아이콘
          if (widget.icon != null) ...[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 제목
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // 설명
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 버튼들
          _buildButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.totalSteps, (index) {
        final isActive = index < widget.currentStep;
        final isCurrent = index == widget.currentStep - 1;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive || isCurrent
                ? AppColors.primary
                : context.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildButtons(bool isDark) {
    final hasSecondary = widget.secondaryButtonText != null;
    final hasPrimary = widget.primaryButtonText != null;

    if (!hasSecondary && !hasPrimary) return const SizedBox.shrink();

    return Row(
      children: [
        // 보조 버튼 (건너뛰기)
        if (hasSecondary) ...[
          Expanded(
            child: TextButton(
              onPressed: widget.onSecondaryTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                widget.secondaryButtonText!,
                style: TextStyle(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (hasPrimary) const SizedBox(width: 12),
        ],

        // 주요 버튼 (다음)
        if (hasPrimary)
          Expanded(
            flex: hasSecondary ? 1 : 0,
            child: ElevatedButton(
              onPressed: widget.onPrimaryTap,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: hasSecondary ? 0 : 48,
                ),
              ),
              child: Text(
                widget.primaryButtonText!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}

/// 롱프레스 안내 손가락 아이콘 애니메이션
class LongPressHint extends StatefulWidget {
  final Rect targetRect;

  const LongPressHint({
    super.key,
    required this.targetRect,
  });

  @override
  State<LongPressHint> createState() => _LongPressHintState();
}

class _LongPressHintState extends State<LongPressHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pressAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.targetRect.center.dx - 16,
      top: widget.targetRect.center.dy - 20,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: const Icon(
              Icons.touch_app,
              size: 40,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
