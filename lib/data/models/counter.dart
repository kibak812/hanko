import 'package:objectbox/objectbox.dart';

/// 카운터 타입
enum CounterType {
  row, // 단 카운터 (메인)
  stitch, // 코 카운터
  pattern, // 패턴 반복 카운터
}

/// 카운터 엔티티
/// 단, 코, 패턴 반복 등 다양한 카운터를 표현
@Entity()
class Counter {
  @Id()
  int id;

  int typeIndex; // CounterType enum index
  String label; // 표시 라벨 (예: "단", "코", "반복")
  int value; // 현재 값
  int? targetValue; // 목표 값 (optional)
  int? resetAt; // 이 값에 도달하면 자동 리셋 (패턴 반복용)
  bool autoResetEnabled; // 자동 리셋 활성화 여부

  Counter({
    this.id = 0,
    this.typeIndex = 0,
    required this.label,
    this.value = 0,
    this.targetValue,
    this.resetAt,
    this.autoResetEnabled = false,
  });

  /// CounterType getter
  @Transient()
  CounterType get type => CounterType.values[typeIndex];

  set type(CounterType value) => typeIndex = value.index;

  /// 현재 진행률 (0.0 ~ 1.0)
  @Transient()
  double get progress {
    if (targetValue == null || targetValue == 0) return 0.0;
    return (value / targetValue!).clamp(0.0, 1.0);
  }

  /// 진행률 퍼센트 (0 ~ 100)
  @Transient()
  int get progressPercent => (progress * 100).round();

  /// 목표 달성 여부
  @Transient()
  bool get isCompleted => targetValue != null && value >= targetValue!;

  /// 자동 리셋 조건 충족 여부
  @Transient()
  bool get shouldAutoReset =>
      autoResetEnabled && resetAt != null && value >= resetAt!;

  Counter copyWith({
    int? id,
    CounterType? type,
    String? label,
    int? value,
    int? targetValue,
    int? resetAt,
    bool? autoResetEnabled,
  }) {
    return Counter(
      id: id ?? this.id,
      typeIndex: type?.index ?? typeIndex,
      label: label ?? this.label,
      value: value ?? this.value,
      targetValue: targetValue ?? this.targetValue,
      resetAt: resetAt ?? this.resetAt,
      autoResetEnabled: autoResetEnabled ?? this.autoResetEnabled,
    );
  }

  /// 단 카운터 생성 헬퍼
  factory Counter.row({
    int id = 0,
    int initialValue = 0,
    int? targetRow,
  }) {
    return Counter(
      id: id,
      typeIndex: CounterType.row.index,
      label: '단',
      value: initialValue,
      targetValue: targetRow,
    );
  }

  /// 코 카운터 생성 헬퍼
  factory Counter.stitch({
    int id = 0,
    int initialValue = 0,
  }) {
    return Counter(
      id: id,
      typeIndex: CounterType.stitch.index,
      label: '코',
      value: initialValue,
    );
  }

  /// 패턴 반복 카운터 생성 헬퍼
  factory Counter.pattern({
    int id = 0,
    int initialValue = 0,
    int? resetAt,
    bool autoReset = false,
  }) {
    return Counter(
      id: id,
      typeIndex: CounterType.pattern.index,
      label: '반복',
      value: initialValue,
      resetAt: resetAt,
      autoResetEnabled: autoReset,
    );
  }

  @override
  String toString() {
    return 'Counter(id: $id, type: $type, label: $label, value: $value, target: $targetValue)';
  }
}
