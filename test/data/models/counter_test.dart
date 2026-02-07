import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/data/models/counter.dart';

void main() {
  group('Counter - progress', () {
    test('targetValue가 null이면 0.0 반환', () {
      final counter = Counter(id: 1, label: 'test', value: 50);
      expect(counter.progress, 0.0);
    });

    test('targetValue가 0이면 0.0 반환', () {
      final counter = Counter(id: 1, label: 'test', value: 50, targetValue: 0);
      expect(counter.progress, 0.0);
    });

    test('value=50, target=100이면 0.5 반환', () {
      final counter =
          Counter(id: 1, label: 'test', value: 50, targetValue: 100);
      expect(counter.progress, 0.5);
    });

    test('value=100, target=100이면 1.0 반환', () {
      final counter =
          Counter(id: 1, label: 'test', value: 100, targetValue: 100);
      expect(counter.progress, 1.0);
    });

    test('value가 target을 초과해도 1.0으로 clamp', () {
      final counter =
          Counter(id: 1, label: 'test', value: 150, targetValue: 100);
      expect(counter.progress, 1.0);
    });
  });

  group('Counter - progressPercent', () {
    test('50% 진행률은 50 반환', () {
      final counter =
          Counter(id: 1, label: 'test', value: 50, targetValue: 100);
      expect(counter.progressPercent, 50);
    });

    test('33.3% 진행률은 33 반환', () {
      final counter =
          Counter(id: 1, label: 'test', value: 1, targetValue: 3);
      expect(counter.progressPercent, 33);
    });

    test('100% 진행률은 100 반환', () {
      final counter =
          Counter(id: 1, label: 'test', value: 100, targetValue: 100);
      expect(counter.progressPercent, 100);
    });
  });

  group('Counter - isCompleted', () {
    test('value < target이면 false', () {
      final counter =
          Counter(id: 1, label: 'test', value: 50, targetValue: 100);
      expect(counter.isCompleted, false);
    });

    test('value == target이면 true', () {
      final counter =
          Counter(id: 1, label: 'test', value: 100, targetValue: 100);
      expect(counter.isCompleted, true);
    });

    test('value > target이면 true', () {
      final counter =
          Counter(id: 1, label: 'test', value: 150, targetValue: 100);
      expect(counter.isCompleted, true);
    });

    test('targetValue가 null이면 false', () {
      final counter = Counter(id: 1, label: 'test', value: 50);
      expect(counter.isCompleted, false);
    });
  });

  group('Counter - shouldAutoReset', () {
    test('autoResetEnabled가 false면 false', () {
      final counter = Counter(
        id: 1,
        label: 'test',
        value: 10,
        resetAt: 10,
        autoResetEnabled: false,
      );
      expect(counter.shouldAutoReset, false);
    });

    test('resetAt이 null이면 false', () {
      final counter = Counter(
        id: 1,
        label: 'test',
        value: 10,
        autoResetEnabled: true,
      );
      expect(counter.shouldAutoReset, false);
    });

    test('value >= resetAt이고 autoResetEnabled이면 true', () {
      final counter = Counter(
        id: 1,
        label: 'test',
        value: 10,
        resetAt: 10,
        autoResetEnabled: true,
      );
      expect(counter.shouldAutoReset, true);
    });

    test('value > resetAt이고 autoResetEnabled이면 true', () {
      final counter = Counter(
        id: 1,
        label: 'test',
        value: 15,
        resetAt: 10,
        autoResetEnabled: true,
      );
      expect(counter.shouldAutoReset, true);
    });

    test('value < resetAt이면 false', () {
      final counter = Counter(
        id: 1,
        label: 'test',
        value: 5,
        resetAt: 10,
        autoResetEnabled: true,
      );
      expect(counter.shouldAutoReset, false);
    });
  });

  group('Counter - factory constructors', () {
    test('Counter.row() 기본값 확인', () {
      final counter = Counter.row(id: 1);
      expect(counter.type, CounterType.row);
      expect(counter.label, '단');
      expect(counter.value, 0);
      expect(counter.targetValue, isNull);
    });

    test('Counter.row() 커스텀 값', () {
      final counter = Counter.row(id: 1, initialValue: 5, targetRow: 100);
      expect(counter.value, 5);
      expect(counter.targetValue, 100);
    });

    test('Counter.stitch() 기본값 확인', () {
      final counter = Counter.stitch(id: 1);
      expect(counter.type, CounterType.stitch);
      expect(counter.label, '코');
      expect(counter.value, 0);
      expect(counter.targetValue, isNull);
    });

    test('Counter.pattern() 기본값 확인', () {
      final counter = Counter.pattern(id: 1);
      expect(counter.type, CounterType.pattern);
      expect(counter.label, '반복');
      expect(counter.value, 0);
      expect(counter.resetAt, isNull);
      expect(counter.autoResetEnabled, false);
    });

    test('Counter.pattern() 자동 리셋 설정', () {
      final counter = Counter.pattern(id: 1, resetAt: 4, autoReset: true);
      expect(counter.resetAt, 4);
      expect(counter.autoResetEnabled, true);
    });

    test('Counter.secondaryRepetition() 기본값 확인', () {
      final counter = Counter.secondaryRepetition(id: 1, label: '무늬반복');
      expect(counter.type, CounterType.pattern);
      expect(counter.secondaryType, SecondaryCounterType.repetition);
      expect(counter.label, '무늬반복');
      expect(counter.value, 0);
      expect(counter.autoResetEnabled, false);
      expect(counter.resetAt, isNull);
    });

    test('Counter.secondaryRepetition() resetAt 설정 시 autoResetEnabled 자동 true', () {
      final counter =
          Counter.secondaryRepetition(id: 1, label: '무늬반복', resetAt: 4);
      expect(counter.resetAt, 4);
      expect(counter.autoResetEnabled, true);
    });

    test('Counter.secondaryGoal() 기본값 확인', () {
      final counter = Counter.secondaryGoal(id: 1, label: '목표');
      expect(counter.type, CounterType.stitch);
      expect(counter.secondaryType, SecondaryCounterType.goal);
      expect(counter.label, '목표');
      expect(counter.value, 0);
      expect(counter.targetValue, isNull);
    });

    test('Counter.secondaryGoal() targetValue 설정', () {
      final counter =
          Counter.secondaryGoal(id: 1, label: '목표', targetValue: 10);
      expect(counter.targetValue, 10);
    });
  });

  group('Counter - copyWith', () {
    test('일부 필드만 변경 (value만)', () {
      final counter = Counter(
        id: 1,
        typeIndex: CounterType.row.index,
        label: '단',
        value: 5,
        targetValue: 100,
      );
      final copied = counter.copyWith(value: 10);

      expect(copied.id, 1);
      expect(copied.type, CounterType.row);
      expect(copied.label, '단');
      expect(copied.value, 10);
      expect(copied.targetValue, 100);
    });

    test('모든 필드 변경', () {
      final counter = Counter(id: 1, label: '원래');
      final copied = counter.copyWith(
        id: 2,
        type: CounterType.stitch,
        label: '변경됨',
        value: 99,
        targetValue: 200,
        resetAt: 10,
        autoResetEnabled: true,
        secondaryType: SecondaryCounterType.goal,
        orderIndex: 3,
        isLinked: true,
      );

      expect(copied.id, 2);
      expect(copied.type, CounterType.stitch);
      expect(copied.label, '변경됨');
      expect(copied.value, 99);
      expect(copied.targetValue, 200);
      expect(copied.resetAt, 10);
      expect(copied.autoResetEnabled, true);
      expect(copied.secondaryType, SecondaryCounterType.goal);
      expect(copied.orderIndex, 3);
      expect(copied.isLinked, true);
    });
  });
}
