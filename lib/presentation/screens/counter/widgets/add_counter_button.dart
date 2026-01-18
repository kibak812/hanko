import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 보조 카운터 추가 버튼
/// - 점선 테두리 + "+" 아이콘
/// - 부모(IntrinsicHeight)에 의해 높이가 SecondaryCounter와 동일하게 맞춰짐
class AddCounterButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddCounterButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: borderColor),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            size: 40,
            color: textSecondary.withAlpha(150),
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
