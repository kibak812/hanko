import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 진행률 바 + 단수 텍스트 + 퍼센트 뱃지
/// ProgressHeader와 ProjectCard에서 공통으로 사용
class ProgressIndicatorBar extends StatelessWidget {
  final double progress;
  final int currentRow;
  final int targetRow;
  final bool isCompleted;
  final Color? backgroundColor;
  final Color? textColor;

  const ProgressIndicatorBar({
    super.key,
    required this.progress,
    required this.currentRow,
    required this.targetRow,
    this.isCompleted = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCompleted = isCompleted || progress >= 1.0;
    final activeColor = effectiveCompleted ? context.success : context.primary;
    final bgColor = backgroundColor ?? context.border;
    final labelColor = textColor ?? context.textSecondary;
    final progressPercent = (progress * 100).round();

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$currentRow/$targetRow단',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$progressPercent%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activeColor,
            ),
          ),
        ),
      ],
    );
  }
}
