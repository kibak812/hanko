import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

/// 프로젝트 정보 바
/// 시작일 + 누적 작업 시간 표시
class ProjectInfoBar extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? completedDate;
  final int totalWorkSeconds;
  final bool isTimerRunning;
  final DateTime? timerStartedAt;
  final VoidCallback? onLongPress;

  const ProjectInfoBar({
    super.key,
    this.startDate,
    this.completedDate,
    required this.totalWorkSeconds,
    required this.isTimerRunning,
    this.timerStartedAt,
    this.onLongPress,
  });

  @override
  State<ProjectInfoBar> createState() => _ProjectInfoBarState();
}

class _ProjectInfoBarState extends State<ProjectInfoBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(ProjectInfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTimerRunning != oldWidget.isTimerRunning) {
      _startTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    _timer?.cancel();
    if (widget.isTimerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// 현재 작업 시간 계산 (타이머 실행 중이면 현재 세션 포함)
  int get _currentWorkSeconds {
    if (!widget.isTimerRunning || widget.timerStartedAt == null) {
      return widget.totalWorkSeconds;
    }
    final sessionSeconds = DateTime.now().difference(widget.timerStartedAt!).inSeconds;
    return widget.totalWorkSeconds + sessionSeconds;
  }

  /// 시간 포맷팅 (예: "2시간 30분 15초", "45분 30초", "30초")
  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('$hours시간');
    if (minutes > 0) parts.add('$minutes분');
    if (seconds > 0 || parts.isEmpty) parts.add('$seconds초');

    return parts.join(' ');
  }

  /// 날짜 포맷팅 (예: "2026/1/19")
  String _formatDate(DateTime date) {
    return DateFormat('yyyy/M/d').format(date);
  }

  /// 날짜 텍스트 생성
  String? _buildDateText() {
    final startDate = widget.startDate;
    final completedDate = widget.completedDate;

    if (startDate == null) return null;

    final dateStr = _formatDate(startDate);

    if (completedDate != null) {
      final completedStr = _formatDate(completedDate);
      return '$dateStr → $completedStr';
    }

    return '$dateStr부터';
  }

  /// 시간 텍스트 생성
  String? _buildTimeText() {
    final workTime = _formatDuration(_currentWorkSeconds);
    if (workTime.isEmpty) return null;

    final completedDate = widget.completedDate;

    if (completedDate != null) {
      return '총 $workTime';
    }

    if (widget.isTimerRunning) {
      return '$workTime째...';
    }

    return workTime;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _buildDateText();
    final timeText = _buildTimeText();

    if (dateText == null && timeText == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final activeColor = widget.isTimerRunning ? AppColors.primary : textColor;
    final textStyle = TextStyle(fontSize: 13, color: activeColor);

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 12),
        child: Row(
          children: [
            if (dateText != null) ...[
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: activeColor,
              ),
              const SizedBox(width: 4),
              Text(dateText, style: textStyle),
            ],
            if (dateText != null && timeText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('·', style: textStyle),
              ),
            if (timeText != null) ...[
              Icon(
                Icons.schedule_outlined,
                size: 14,
                color: activeColor,
              ),
              const SizedBox(width: 4),
              Text(timeText, style: textStyle),
            ],
          ],
        ),
      ),
    );
  }
}
