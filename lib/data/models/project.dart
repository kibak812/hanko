import 'package:objectbox/objectbox.dart';
import 'counter.dart';
import 'row_memo.dart';

/// 프로젝트 상태
enum ProjectStatus {
  inProgress, // 진행 중
  completed, // 완료
  paused, // 일시정지
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

  // Undo 히스토리 (JSON string으로 저장)
  String rowHistoryJson;

  // 관계 설정
  final rowCounter = ToOne<Counter>();
  final stitchCounter = ToOne<Counter>();
  final patternCounter = ToOne<Counter>();
  final memos = ToMany<RowMemo>();

  Project({
    this.id = 0,
    required this.name,
    this.statusIndex = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.rowHistoryJson = '[]',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============ Status Getter/Setter ============

  @Transient()
  ProjectStatus get status => ProjectStatus.values[statusIndex];

  set status(ProjectStatus value) => statusIndex = value.index;

  // ============ Row History ============

  @Transient()
  List<int> get rowHistory {
    try {
      final list = rowHistoryJson
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => int.parse(s.trim()))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  set rowHistory(List<int> value) {
    rowHistoryJson = '[${value.join(',')}]';
  }

  void addToHistory(int value) {
    final history = rowHistory;
    history.add(value);
    // 최대 50개까지만 유지
    if (history.length > 50) {
      history.removeAt(0);
    }
    rowHistory = history;
  }

  int? popFromHistory() {
    final history = rowHistory;
    if (history.isEmpty) return null;
    final value = history.removeLast();
    rowHistory = history;
    return value;
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
  bool get canUndo => rowHistory.isNotEmpty;

  // ============ Row Operations ============

  /// 단 증가
  void incrementRow() {
    final counter = rowCounter.target;
    if (counter != null) {
      addToHistory(counter.value);
      counter.value++;
      _updateTimestamp();
    }
  }

  /// 단 감소
  void decrementRow() {
    final counter = rowCounter.target;
    if (counter != null && counter.value > 0) {
      addToHistory(counter.value);
      counter.value--;
      _updateTimestamp();
    }
  }

  /// 단 설정
  void setRow(int value) {
    final counter = rowCounter.target;
    if (counter != null && value >= 0) {
      addToHistory(counter.value);
      counter.value = value;
      _updateTimestamp();
    }
  }

  /// 되돌리기 (Undo)
  bool undo() {
    final previousValue = popFromHistory();
    if (previousValue == null) return false;

    final counter = rowCounter.target;
    if (counter != null) {
      counter.value = previousValue;
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
      counter.value++;
      _updateTimestamp();
    }
  }

  /// 코 감소
  void decrementStitch() {
    final counter = stitchCounter.target;
    if (counter != null && counter.value > 0) {
      counter.value--;
      _updateTimestamp();
    }
  }

  /// 코 리셋
  void resetStitch() {
    final counter = stitchCounter.target;
    if (counter != null) {
      counter.value = 0;
      _updateTimestamp();
    }
  }

  // ============ Pattern Operations ============

  /// 패턴 증가
  void incrementPattern() {
    final counter = patternCounter.target;
    if (counter != null) {
      counter.value++;
      // 자동 리셋 체크
      if (counter.shouldAutoReset) {
        counter.value = 0;
      }
      _updateTimestamp();
    }
  }

  /// 패턴 감소
  void decrementPattern() {
    final counter = patternCounter.target;
    if (counter != null && counter.value > 0) {
      counter.value--;
      _updateTimestamp();
    }
  }

  /// 패턴 리셋
  void resetPattern() {
    final counter = patternCounter.target;
    if (counter != null) {
      counter.value = 0;
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
