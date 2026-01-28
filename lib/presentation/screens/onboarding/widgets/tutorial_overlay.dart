import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 튜토리얼 스포트라이트 오버레이
/// - 어두운 배경 + 투명 구멍으로 대상 위젯 강조
/// - 펄스 애니메이션으로 주목도 상승
class TutorialOverlay extends StatefulWidget {
  final Rect? targetRect;
  final double padding;
  final VoidCallback? onTap;
  final bool showPulse;

  const TutorialOverlay({
    super.key,
    this.targetRect,
    this.padding = 8.0,
    this.onTap,
    this.showPulse = true,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _SpotlightPainter(
          targetRect: widget.targetRect,
          padding: widget.padding,
          pulseAnimation: widget.showPulse ? _pulseAnimation : null,
        ),
      ),
    );
  }
}

/// 스포트라이트 페인터
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double padding;
  final Animation<double>? pulseAnimation;

  _SpotlightPainter({
    this.targetRect,
    this.padding = 8.0,
    this.pulseAnimation,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    // 전체 어두운 배경
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect != null) {
      // 타겟 영역에 투명 구멍 만들기
      final expandedRect = Rect.fromLTRB(
        targetRect!.left - padding,
        targetRect!.top - padding,
        targetRect!.right + padding,
        targetRect!.bottom + padding,
      );

      final holePath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(expandedRect, const Radius.circular(12)),
        );

      // 배경에서 구멍 제거
      final combinedPath = Path.combine(
        PathOperation.difference,
        backgroundPath,
        holePath,
      );

      canvas.drawPath(combinedPath, paint);

      // 펄스 애니메이션 (glow 효과)
      if (pulseAnimation != null) {
        final pulseValue = pulseAnimation!.value;
        final glowPaint = Paint()
          ..color = AppColors.primary.withValues(alpha: 0.4 * (1 - pulseValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 + (pulseValue * 6);

        final glowRect = Rect.fromLTRB(
          expandedRect.left - (pulseValue * 8),
          expandedRect.top - (pulseValue * 8),
          expandedRect.right + (pulseValue * 8),
          expandedRect.bottom + (pulseValue * 8),
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(glowRect, const Radius.circular(16)),
          glowPaint,
        );
      }
    } else {
      canvas.drawPath(backgroundPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.padding != padding;
  }
}

/// 튜토리얼 오버레이를 애니메이션과 함께 표시
class AnimatedTutorialOverlay extends StatefulWidget {
  final Rect? targetRect;
  final double padding;
  final Widget? child;
  final VoidCallback? onBackgroundTap;

  const AnimatedTutorialOverlay({
    super.key,
    this.targetRect,
    this.padding = 8.0,
    this.child,
    this.onBackgroundTap,
  });

  @override
  State<AnimatedTutorialOverlay> createState() => _AnimatedTutorialOverlayState();
}

class _AnimatedTutorialOverlayState extends State<AnimatedTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          TutorialOverlay(
            targetRect: widget.targetRect,
            padding: widget.padding,
            onTap: widget.onBackgroundTap,
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

/// GlobalKey로부터 Rect 얻기
Rect? getRectFromKey(GlobalKey? key) {
  if (key == null || key.currentContext == null) return null;

  final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
  if (renderBox == null || !renderBox.hasSize) return null;

  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}
