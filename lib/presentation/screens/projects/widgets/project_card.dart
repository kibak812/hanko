import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/project.dart';

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
    final progressPercent = project.progressPercent;
    final isCompleted = project.status == ProjectStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
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
                  const Text('✅', style: TextStyle(fontSize: 20)),
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
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatLastUpdated(project.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      _buildTimeInfoSection(isDark, isCompleted),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
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
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progress,
                        backgroundColor:
                            isDark ? AppColors.borderDark : AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${project.currentRow}/${project.targetRow}단',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$progressPercent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                '${project.currentRow}단',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
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

  /// 날짜 포맷 (올해: M/d, 작년 이전: yy년 M/d)
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year) {
      return DateFormat('M/d').format(date);
    } else {
      return DateFormat("yy'년' M/d").format(date);
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
      return '${_formatDate(startDate)} → ${_formatDate(completedDate)}';
    }

    if (startDate != null) {
      return '${_formatDate(startDate)}부터';
    }

    return null;
  }

  /// 작업 시간 포맷 (초 포함)
  String? _formatWorkTime() {
    final totalSeconds = project.totalWorkSeconds;
    if (totalSeconds == 0) return null;

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('$hours시간');
    if (minutes > 0) parts.add('$minutes분');
    if (seconds > 0 || parts.isEmpty) parts.add('$seconds초');

    return parts.join(' ');
  }

  /// 시간 정보 섹션 빌드 (날짜 범위 + 작업 시간)
  Widget _buildTimeInfoSection(bool isDark, bool isCompleted) {
    final dateRange = _formatDateRange();
    final workTime = _formatWorkTime();

    if (dateRange == null && workTime == null) {
      return const SizedBox.shrink();
    }

    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
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
