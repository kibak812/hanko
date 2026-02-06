import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 보조 카운터 추가 버튼
/// - 점선 테두리 + "+" 아이콘
/// - isFullWidth: true면 전체 너비로 표시 (보조 카운터가 없을 때)
/// - 부모(IntrinsicHeight)에 의해 높이가 SecondaryCounter와 동일하게 맞춰짐
class AddCounterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isFullWidth;

  const AddCounterButton({
    super.key,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = context.border;
    final textSecondary = context.textSecondary;

    // 전체 너비일 때는 높이를 고정, 아닐 때는 부모에 맞춤
    final minHeight = isFullWidth ? 72.0 : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: borderColor),
          child: Center(
            // 전체 너비(72px): 36px 아이콘, 그리드(SecondaryCounter 높이 맞춤): 40px 아이콘
            child: Icon(
              Icons.add_rounded,
              size: isFullWidth ? 36 : 40,
              color: textSecondary.withAlpha(150),
            ),
          ),
        ),
      ),
    );
  }
}

/// 점선 테두리 페인터
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    path.addRRect(rrect);

    // 점선 그리기
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final result = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        result.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }
    canvas.drawPath(result, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color;
}
