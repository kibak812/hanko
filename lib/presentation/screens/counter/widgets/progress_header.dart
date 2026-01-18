import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/widget_extensions.dart';

/// 상단 진행률 헤더
/// 프로젝트명 + 진행률 바
/// - 탭: 프로젝트 목록으로 이동
/// - 롱프레스: 인라인 편집기 표시
class ProgressHeader extends StatelessWidget {
  final String projectName;
  final int currentRow;
  final int? targetRow;
  final double progress;
  final VoidCallback? onTap;
  final void Function(Rect sourceRect)? onLongPress;

  const ProgressHeader({
    super.key,
    required this.projectName,
    required this.currentRow,
    this.targetRow,
    required this.progress,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressPercent = (progress * 100).round();
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress != null
          ? () => onLongPress!(context.getWidgetRect())
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🧶 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    projectName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ],
            ),
            if (targetRow != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? successColor : AppColors.primary,
                        ),
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
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: progress >= 1.0
                          ? successColor.withAlpha(50)
                          : AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$progressPercent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: progress >= 1.0 ? successColor : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
