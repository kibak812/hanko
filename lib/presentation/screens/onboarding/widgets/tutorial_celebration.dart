import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// 튜토리얼 완료 축하 화면
class TutorialCelebration extends StatefulWidget {
  final VoidCallback? onComplete;

  const TutorialCelebration({
    super.key,
    this.onComplete,
  });

  @override
  State<TutorialCelebration> createState() => _TutorialCelebrationState();
}

class _TutorialCelebrationState extends State<TutorialCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleController.forward();
    _confettiController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Stack(
          children: [
            // 컨페티 애니메이션
            ...List.generate(30, (index) {
              return _ConfettiParticle(
                animation: _confettiController,
                index: index,
                screenSize: screenSize,
              );
            }),

            // 중앙 콘텐츠
            Center(
              child: AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: _buildContent(isDark),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 56,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // 제목
          Text(
            AppStrings.tutorialCompleteTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // 설명
          Text(
            AppStrings.tutorialCompleteDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                AppStrings.startFirstProject,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 컨페티 파티클
class _ConfettiParticle extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Size screenSize;

  const _ConfettiParticle({
    required this.animation,
    required this.index,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final startX = random.nextDouble() * screenSize.width;
    final startY = -50.0 - (random.nextDouble() * 100);
    final endY = screenSize.height + 100;
    final horizontalDrift = (random.nextDouble() - 0.5) * 200;
    final rotation = random.nextDouble() * 4 * math.pi;
    final size = 8.0 + random.nextDouble() * 8;
    final delay = random.nextDouble() * 0.3;

    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      Colors.pink,
      Colors.purple,
      Colors.cyan,
    ];
    final color = colors[index % colors.length];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        final currentY = startY + (endY - startY) * progress;
        final currentX = startX + horizontalDrift * math.sin(progress * math.pi * 2);
        final currentRotation = rotation * progress;
        final opacity = progress < 0.8 ? 1.0 : (1 - progress) / 0.2;

        return Positioned(
          left: currentX,
          top: currentY,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: currentRotation,
              child: Container(
                width: size,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 간단한 체크마크 애니메이션
class CheckMarkAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final VoidCallback? onComplete;

  const CheckMarkAnimation({
    super.key,
    this.size = 80,
    this.color = AppColors.success,
    this.onComplete,
  });

  @override
  State<CheckMarkAnimation> createState() => _CheckMarkAnimationState();
}

class _CheckMarkAnimationState extends State<CheckMarkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CheckMarkPainter(
            circleProgress: _circleAnimation.value,
            checkProgress: _checkAnimation.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _CheckMarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;

  _CheckMarkPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // 원 그리기
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * circleProgress,
      false,
      circlePaint,
    );

    // 체크마크 그리기
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final startPoint = Offset(size.width * 0.28, size.height * 0.52);
      final midPoint = Offset(size.width * 0.45, size.height * 0.68);
      final endPoint = Offset(size.width * 0.72, size.height * 0.35);

      final path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);

      if (checkProgress <= 0.5) {
        // 첫 번째 선
        final progress = checkProgress * 2;
        path.lineTo(
          startPoint.dx + (midPoint.dx - startPoint.dx) * progress,
          startPoint.dy + (midPoint.dy - startPoint.dy) * progress,
        );
      } else {
        // 첫 번째 선 완성 + 두 번째 선
        path.lineTo(midPoint.dx, midPoint.dy);
        final progress = (checkProgress - 0.5) * 2;
        path.lineTo(
          midPoint.dx + (endPoint.dx - midPoint.dx) * progress,
          midPoint.dy + (endPoint.dy - midPoint.dy) * progress,
        );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckMarkPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkProgress != checkProgress;
  }
}
