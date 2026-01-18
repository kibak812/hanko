import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'counter.dart';
import 'row_memo.dart';

/// 프로젝트 상태
enum ProjectStatus {
  inProgress, // 진행 중
  completed, // 완료
  paused, // 일시정지
}

/// 카운터 액션 (되돌리기용)
class CounterAction {
  final String counterType; // 'row', 'stitch', 'pattern', 'secondary'
  final int previousValue;
  final int newValue;
  final DateTime timestamp;
  final int? counterId; // 보조 카운터용 ID (secondary 타입일 때 사용)

  CounterAction({
    required this.counterType,
    required this.previousValue,
    required this.newValue,
    this.counterId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': counterType,
        'prev': previousValue,
        'new': newValue,
        'ts': timestamp.millisecondsSinceEpoch,
        if (counterId != null) 'cid': counterId,
      };

  factory CounterAction.fromJson(Map<String, dynamic> json) {
    return CounterAction(
      counterType: json['type'] as String,
      previousValue: json['prev'] as int,
      newValue: json['new'] as int,
      counterId: json['cid'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int),
    );
  }
}

/// 뜨개질 프로젝트 엔티티
@Entity()
class Project {
  @Id()
  int id;

  String name;
  int statusIndex; // ProjectStatus enum index

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  // 공통 카운터 히스토리 (JSON string으로 저장)
  String counterHistoryJson;

  // 관계 설정
  final rowCounter = ToOne<Counter>();
  final stitchCounter = ToOne<Counter>();
  final patternCounter = ToOne<Counter>();
  final secondaryCounters = ToMany<Counter>(); // 동적 보조 카운터들
  final memos = ToMany<RowMemo>();

  Project({
    this.id = 0,
    required this.name,
    this.statusIndex = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.counterHistoryJson = '[]',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============ Status Getter/Setter ============

  @Transient()
  ProjectStatus get status => ProjectStatus.values[statusIndex];

  set status(ProjectStatus value) => statusIndex = value.index;

  // ============ Counter History ============

  @Transient()
  List<CounterAction> get counterHistory {
    try {
      if (counterHistoryJson == '[]' || counterHistoryJson.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(counterHistoryJson);
      return jsonList
          .map((item) => CounterAction.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  set counterHistory(List<CounterAction> value) {
    if (value.isEmpty) {
      counterHistoryJson = '[]';
      return;
    }
    final jsonList = value.map((a) => a.toJson()).toList();
    counterHistoryJson = jsonEncode(jsonList);
  }

  void addCounterAction(String counterType, int previousValue, int newValue,
      {int? counterId}) {
    final history = counterHistory;
    history.add(CounterAction(
      counterType: counterType,
      previousValue: previousValue,
      newValue: newValue,
      counterId: counterId,
    ));
    // 최대 50개까지만 유지
    if (history.length > 50) {
      history.removeAt(0);
    }
    counterHistory = history;
  }

  CounterAction? popCounterAction() {
    final history = counterHistory;
    if (history.isEmpty) return null;
    final action = history.removeLast();
    counterHistory = history;
    return action;
  }

  // ============ Getters ============

  /// 현재 단
  @Transient()
  int get currentRow => rowCounter.target?.value ?? 0;

  /// 목표 단
  @Transient()
  int? get targetRow => rowCounter.target?.targetValue;

  /// 진행률 (0.0 ~ 1.0)
  @Transient()
  double get progress => rowCounter.target?.progress ?? 0.0;

  /// 진행률 퍼센트
  @Transient()
  int get progressPercent => rowCounter.target?.progressPercent ?? 0;

  /// 완료 여부
  @Transient()
  bool get isCompleted => rowCounter.target?.isCompleted ?? false;

  /// 현재 단에 해당하는 메모
  @Transient()
  RowMemo? get currentMemo {
    try {
      return memos.firstWhere((m) => m.rowNumber == currentRow);
    } catch (_) {
      return null;
    }
  }

  /// 다음 메모 (현재 단 이후 가장 가까운 메모)
  @Transient()
  RowMemo? get nextMemo {
    final upcomingMemos = memos
        .where((m) => m.rowNumber > currentRow)
        .toList()
      ..sort((a, b) => a.rowNumber.compareTo(b.rowNumber));
    return upcomingMemos.isEmpty ? null : upcomingMemos.first;
  }

  /// 되돌리기 가능 여부
  @Transient()
  bool get canUndo => counterHistory.isNotEmpty;

  // ============ Row Operations ============

  /// 단 증가
  void incrementRow() {
    final counter = rowCounter.target;
    if (counter != null) {
      final prevValue = counter.value;
      counter.value++;
      addCounterAction('row', prevValue, counter.value);
      _updateTimestamp();

      // 연동된 보조 카운터도 증가
      for (final sc in secondaryCounters.where((c) => c.isLinked)) {
        incrementSecondaryCounter(sc.id);
      }
    }
  }

  /// 단 감소
  void decrementRow() {
    final counter = rowCounter.target;
    if (counter != null && counter.value > 0) {
      final prevValue = counter.value;
      counter.value--;
      addCounterAction('row', prevValue, counter.value);
      _updateTimestamp();

      // 연동된 보조 카운터도 감소
      for (final sc in secondaryCounters.where((c) => c.isLinked)) {
        decrementSecondaryCounter(sc.id);
      }
    }
  }

  /// 단 설정
  void setRow(int value) {
    final counter = rowCounter.target;
    if (counter != null && value >= 0) {
      final prevValue = counter.value;
      counter.value = value;
      addCounterAction('row', prevValue, counter.value);
      _updateTimestamp();
    }
  }

  /// 되돌리기 (Undo) - 모든 카운터 지원 (보조 카운터 포함)
  bool undo() {
    final action = popCounterAction();
    if (action == null) return false;

    Counter? counter;
    switch (action.counterType) {
      case 'row':
        counter = rowCounter.target;
        break;
      case 'stitch':
        counter = stitchCounter.target;
        break;
      case 'pattern':
        counter = patternCounter.target;
        break;
      case 'secondary':
        if (action.counterId != null) {
          try {
            counter = secondaryCounters.firstWhere(
              (c) => c.id == action.counterId,
            );
          } catch (_) {
            counter = null;
          }
        }
        break;
    }

    if (counter != null) {
      counter.value = action.previousValue;
      _updateTimestamp();
      return true;
    }
    return false;
  }

  // ============ Stitch Operations ============

  /// 코 증가
  void incrementStitch() {
    final counter = stitchCounter.target;
    if (counter != null) {
      final prevValue = counter.value;
      counter.value++;
      addCounterAction('stitch', prevValue, counter.value);
      _updateTimestamp();
    }
  }

  /// 코 감소
  void decrementStitch() {
    final counter = stitchCounter.target;
    if (counter != null && counter.value > 0) {
      final prevValue = counter.value;
      counter.value--;
      addCounterAction('stitch', prevValue, counter.value);
      _updateTimestamp();
    }
  }

  /// 코 리셋
  void resetStitch() {
    final counter = stitchCounter.target;
    if (counter != null) {
      final prevValue = counter.value;
      counter.value = 0;
      addCounterAction('stitch', prevValue, counter.value);
      _updateTimestamp();
    }
  }

  // ============ Pattern Operations ============

  /// 패턴 증가
  void incrementPattern() {
    final counter = patternCounter.target;
    if (counter != null) {
      final prevValue = counter.value;
      counter.value++;
      // 자동 리셋 체크
      if (counter.shouldAutoReset) {
        counter.value = 0;
      }
      addCounterAction('pattern', prevValue, counter.value);
      _updateTimestamp();
    }
  }

  /// 패턴 감소
  void decrementPattern() {
    final counter = patternCounter.target;
    if (counter != null && counter.value > 0) {
      final prevValue = counter.value;
      counter.value--;
      addCounterAction('pattern', prevValue, counter.value);
      _updateTimestamp();
    }
  }

  /// 패턴 리셋
  void resetPattern() {
    final counter = patternCounter.target;
    if (counter != null) {
      final prevValue = counter.value;
      counter.value = 0;
      addCounterAction('pattern', prevValue, counter.value);
      _updateTimestamp();
    }
  }

  // ============ Secondary Counter Operations ============

  /// 보조 카운터 ID로 찾기
  Counter? getSecondaryCounter(int counterId) {
    try {
      return secondaryCounters.firstWhere((c) => c.id == counterId);
    } catch (_) {
      return null;
    }
  }

  /// 보조 카운터 증가 (자동 리셋 포함)
  /// Returns: (didAutoReset, isGoalReached)
  (bool, bool) incrementSecondaryCounter(int counterId) {
    final counter = getSecondaryCounter(counterId);
    if (counter == null) return (false, false);

    final prevValue = counter.value;
    counter.value++;

    bool didAutoReset = false;
    bool isGoalReached = false;

    // 반복 유형: 자동 리셋 체크
    if (counter.secondaryType == SecondaryCounterType.repetition &&
        counter.shouldAutoReset) {
      counter.value = 0;
      didAutoReset = true;
    }

    // 횟수 유형: 목표 달성 체크
    if (counter.secondaryType == SecondaryCounterType.goal &&
        counter.isCompleted) {
      isGoalReached = true;
    }

    addCounterAction('secondary', prevValue, counter.value, counterId: counterId);
    _updateTimestamp();
    return (didAutoReset, isGoalReached);
  }

  /// 보조 카운터 감소
  void decrementSecondaryCounter(int counterId) {
    final counter = getSecondaryCounter(counterId);
    if (counter != null && counter.value > 0) {
      final prevValue = counter.value;
      counter.value--;
      addCounterAction('secondary', prevValue, counter.value, counterId: counterId);
      _updateTimestamp();
    }
  }

  /// 보조 카운터 리셋
  void resetSecondaryCounter(int counterId) {
    final counter = getSecondaryCounter(counterId);
    if (counter != null) {
      final prevValue = counter.value;
      counter.value = 0;
      addCounterAction('secondary', prevValue, counter.value, counterId: counterId);
      _updateTimestamp();
    }
  }

  /// 보조 카운터 값 직접 설정
  void setSecondaryCounterValue(int counterId, int value) {
    final counter = getSecondaryCounter(counterId);
    if (counter != null && value >= 0) {
      final prevValue = counter.value;
      counter.value = value;
      addCounterAction('secondary', prevValue, counter.value, counterId: counterId);
      _updateTimestamp();
    }
  }

  // ============ Status Operations ============

  /// 프로젝트 완료로 마크
  void markAsCompleted() {
    status = ProjectStatus.completed;
    _updateTimestamp();
  }

  /// 프로젝트 일시정지
  void pause() {
    status = ProjectStatus.paused;
    _updateTimestamp();
  }

  /// 프로젝트 재개
  void resume() {
    status = ProjectStatus.inProgress;
    _updateTimestamp();
  }

  void _updateTimestamp() {
    updatedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, row: $currentRow/$targetRow, status: $status)';
  }
}
