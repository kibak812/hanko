import 'counter.dart';
import 'project.dart';
import 'row_memo.dart';

// ============ Counter 직렬화 ============

extension CounterBackupJson on Counter {
  Map<String, dynamic> toBackupJson() {
    return {
      'typeIndex': typeIndex,
      'label': label,
      'value': value,
      'targetValue': targetValue,
      'resetAt': resetAt,
      'autoResetEnabled': autoResetEnabled,
      'secondaryTypeIndex': secondaryTypeIndex,
      'orderIndex': orderIndex,
      'isLinked': isLinked,
    };
  }
}

Counter counterFromBackupJson(Map<String, dynamic> json) {
  final typeIndex = json['typeIndex'] as int? ?? 0;
  final secondaryTypeIndex = json['secondaryTypeIndex'] as int? ?? 0;

  return Counter(
    id: 0,
    typeIndex: (typeIndex >= 0 && typeIndex <= 2) ? typeIndex : 0,
    label: json['label'] as String? ?? '',
    value: json['value'] as int? ?? 0,
    targetValue: json['targetValue'] as int?,
    resetAt: json['resetAt'] as int?,
    autoResetEnabled: json['autoResetEnabled'] as bool? ?? false,
    secondaryTypeIndex:
        (secondaryTypeIndex >= 0 && secondaryTypeIndex <= 1)
            ? secondaryTypeIndex
            : 0,
    orderIndex: json['orderIndex'] as int? ?? 0,
    isLinked: json['isLinked'] as bool? ?? false,
  );
}

// ============ RowMemo 직렬화 ============

extension RowMemoBackupJson on RowMemo {
  Map<String, dynamic> toBackupJson() {
    return {
      'rowNumber': rowNumber,
      'content': content,
      'notified': notified,
    };
  }
}

RowMemo rowMemoFromBackupJson(Map<String, dynamic> json) {
  return RowMemo(
    id: 0,
    rowNumber: json['rowNumber'] as int? ?? 0,
    content: json['content'] as String? ?? '',
    notified: json['notified'] as bool? ?? false,
  );
}

// ============ Project 직렬화 ============

extension ProjectBackupJson on Project {
  Map<String, dynamic> toBackupJson() {
    // timerStartedAt가 있으면 현재 세션 시간을 합산
    int workSeconds = totalWorkSeconds;
    if (timerStartedAt != null) {
      workSeconds += DateTime.now().difference(timerStartedAt!).inSeconds;
    }

    return {
      'name': name,
      'statusIndex': statusIndex,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'startDate': startDate?.millisecondsSinceEpoch,
      'completedDate': completedDate?.millisecondsSinceEpoch,
      'totalWorkSeconds': workSeconds,
      'counterHistoryJson': counterHistoryJson,
      'rowCounter': rowCounter.target?.toBackupJson(),
      'stitchCounter': stitchCounter.target?.toBackupJson(),
      'patternCounter': patternCounter.target?.toBackupJson(),
      'secondaryCounters':
          secondaryCounters.map((c) => c.toBackupJson()).toList(),
      'memos': memos.map((m) => m.toBackupJson()).toList(),
    };
  }
}

/// JSON millisecondsSinceEpoch 값을 DateTime으로 변환하는 헬퍼
DateTime? _dateTimeFromMs(dynamic value) {
  if (value == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(value as int);
}

Project projectFromBackupJson(Map<String, dynamic> json) {
  final statusIndex = json['statusIndex'] as int? ?? 0;

  return Project(
    id: 0,
    name: json['name'] as String? ?? '',
    statusIndex: (statusIndex >= 0 && statusIndex <= 2) ? statusIndex : 0,
    createdAt: _dateTimeFromMs(json['createdAt']) ?? DateTime.now(),
    updatedAt: _dateTimeFromMs(json['updatedAt']) ?? DateTime.now(),
    startDate: _dateTimeFromMs(json['startDate']),
    completedDate: _dateTimeFromMs(json['completedDate']),
    totalWorkSeconds: json['totalWorkSeconds'] as int? ?? 0,
    timerStartedAt: null,
    // 의도적으로 초기화: 복원 시 카운터 ID가 새로 발급되어
    // undo 히스토리의 cid 참조가 깨지므로 빈 배열로 리셋
    counterHistoryJson: '[]',
  );
}
