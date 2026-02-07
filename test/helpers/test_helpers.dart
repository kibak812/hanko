import 'package:hanko_hanko/data/models/counter.dart';
import 'package:hanko_hanko/data/models/project.dart';
import 'package:hanko_hanko/data/models/row_memo.dart';

/// 테스트용 고정 DateTime 상수 (flaky 테스트 방지)
final fixedNow = DateTime(2025, 6, 15, 14, 30, 0);
final fixedYesterday = DateTime(2025, 6, 14, 14, 30, 0);
final fixedLastWeek = DateTime(2025, 6, 8, 14, 30, 0);
final fixedLastYear = DateTime(2024, 12, 25, 10, 0, 0);

/// 테스트용 Project 팩토리
/// [id]를 반드시 1 이상으로 부여 (ObjectBox ToMany id=0 문제 방지)
Project createTestProject({
  int id = 1,
  String name = 'Test Project',
  int statusIndex = 0,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? startDate,
  DateTime? completedDate,
  int totalWorkSeconds = 0,
  DateTime? timerStartedAt,
  String counterHistoryJson = '[]',
  Counter? rowCounter,
  Counter? stitchCounter,
  Counter? patternCounter,
  List<Counter>? secondaryCounters,
  List<RowMemo>? memos,
}) {
  final project = Project(
    id: id,
    name: name,
    statusIndex: statusIndex,
    createdAt: createdAt ?? fixedNow,
    updatedAt: updatedAt ?? fixedNow,
    startDate: startDate,
    completedDate: completedDate,
    totalWorkSeconds: totalWorkSeconds,
    timerStartedAt: timerStartedAt,
    counterHistoryJson: counterHistoryJson,
  );

  if (rowCounter != null) {
    project.rowCounter.target = rowCounter;
  }
  if (stitchCounter != null) {
    project.stitchCounter.target = stitchCounter;
  }
  if (patternCounter != null) {
    project.patternCounter.target = patternCounter;
  }
  if (secondaryCounters != null) {
    project.secondaryCounters.addAll(secondaryCounters);
  }
  if (memos != null) {
    project.memos.addAll(memos);
  }

  return project;
}

/// 테스트용 Counter 팩토리
Counter createTestCounter({
  int id = 1,
  int typeIndex = 0,
  String label = 'Test',
  int value = 0,
  int? targetValue,
  int? resetAt,
  bool autoResetEnabled = false,
  int secondaryTypeIndex = 0,
  int orderIndex = 0,
  bool isLinked = false,
}) {
  return Counter(
    id: id,
    typeIndex: typeIndex,
    label: label,
    value: value,
    targetValue: targetValue,
    resetAt: resetAt,
    autoResetEnabled: autoResetEnabled,
    secondaryTypeIndex: secondaryTypeIndex,
    orderIndex: orderIndex,
    isLinked: isLinked,
  );
}

/// 테스트용 RowMemo 팩토리
RowMemo createTestMemo({
  int id = 1,
  int rowNumber = 1,
  String content = 'Test memo',
  bool notified = false,
}) {
  return RowMemo(
    id: id,
    rowNumber: rowNumber,
    content: content,
    notified: notified,
  );
}
