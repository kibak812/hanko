import 'package:intl/intl.dart';

/// 시간 포맷팅 (예: "2시간 30분 15초", "45분 30초", "30초")
String formatDuration(int totalSeconds) {
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

/// 날짜 포맷팅 (yyyy/M/d)
String formatDateFull(DateTime date) {
  return DateFormat('yyyy/M/d').format(date);
}

/// 날짜 포맷팅 - 간결 (올해: M/d, 다른 해: yy년 M/d)
String formatDateCompact(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year) {
    return DateFormat('M/d').format(date);
  } else {
    return DateFormat("yy'년' M/d").format(date);
  }
}
