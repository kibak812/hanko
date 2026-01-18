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

  /// 정보 텍스트 생성
  String _buildInfoText() {
    final startDate = widget.startDate;
    final completedDate = widget.completedDate;
    final workTime = _formatDuration(_currentWorkSeconds);

    // 시작일이 없으면 빈 문자열
    if (startDate == null) return '';

    final dateStr = _formatDate(startDate);

    // 완료된 경우
    if (completedDate != null) {
      final completedStr = _formatDate(completedDate);
      if (workTime.isNotEmpty) {
        return '$dateStr부터 $workTime 동안 $completedStr까지';
      }
      return '$dateStr부터 $completedStr까지';
    }

    // 진행 중 - 타이머 실행 중
    if (widget.isTimerRunning) {
      if (workTime.isNotEmpty) {
        return '$dateStr부터 $workTime째...';
      }
      return '$dateStr부터 작업 중...';
    }

    // 진행 중 - 타이머 정지
    if (workTime.isNotEmpty) {
      return '$dateStr부터 $workTime 동안 작업 중';
    }
    return '$dateStr부터 작업 중';
  }

  @override
  Widget build(BuildContext context) {
    final infoText = _buildInfoText();
    if (infoText.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 12),
        child: Row(
          children: [
            if (widget.isTimerRunning)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.timer,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            Expanded(
              child: Text(
                infoText,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isTimerRunning ? AppColors.primary : textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
