import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/project.dart';
import '../../../widgets/progress_indicator_bar.dart';

/// 프로젝트 카드 위젯
class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = project.status == ProjectStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(
                  color: context.border,
                ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isCompleted) ...[
                  Icon(Icons.check_circle, size: 20, color: AppColors.success),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatLastUpdated(project.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                      _buildTimeInfoSection(context, isCompleted),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: context.textSecondary,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text(AppStrings.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.delete,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (project.targetRow != null) ...[
              const SizedBox(height: 12),
              ProgressIndicatorBar(
                progress: project.progress,
                currentRow: project.currentRow,
                targetRow: project.targetRow!,
                isCompleted: isCompleted,
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                '${project.currentRow}단',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '방금 전';
      }
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return AppStrings.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('M월 d일').format(dateTime);
    }
  }

  /// 날짜 범위 포맷
  String? _formatDateRange() {
    final startDate = project.startDate;
    final completedDate = project.completedDate;
    final isCompleted = project.status == ProjectStatus.completed;

    if (startDate == null && completedDate == null) {
      return null;
    }

    if (isCompleted && startDate != null && completedDate != null) {
      return '${formatDateCompact(startDate)} → ${formatDateCompact(completedDate)}';
    }

    if (startDate != null) {
      return '${formatDateCompact(startDate)}부터';
    }

    return null;
  }

  /// 작업 시간 포맷
  String? _formatWorkTime() {
    final totalSeconds = project.totalWorkSeconds;
    if (totalSeconds == 0) return null;
    final result = formatDuration(totalSeconds);
    return result.isEmpty ? null : result;
  }

  /// 시간 정보 섹션 빌드 (날짜 범위 + 작업 시간)
  Widget _buildTimeInfoSection(BuildContext context, bool isCompleted) {
    final dateRange = _formatDateRange();
    final workTime = _formatWorkTime();

    if (dateRange == null && workTime == null) {
      return const SizedBox.shrink();
    }

    final textColor = context.textSecondary;
    final textStyle = TextStyle(fontSize: 12, color: textColor);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          if (dateRange != null) ...[
            Icon(Icons.calendar_today_outlined, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(dateRange, style: textStyle),
          ],
          if (dateRange != null && workTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('·', style: textStyle),
            ),
          if (workTime != null) ...[
            Icon(Icons.schedule_outlined, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(isCompleted ? '총 $workTime' : workTime, style: textStyle),
          ],
        ],
      ),
    );
  }
}
