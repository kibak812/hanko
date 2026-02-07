import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/data/models/counter.dart';
import 'package:hanko_hanko/data/models/project.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('CounterAction - 직렬화', () {
    test('toJson -> fromJson 왕복 변환 (counterId 없음)', () {
      final ts = DateTime(2025, 6, 15, 10, 0, 0);
      final action = CounterAction(
        counterType: 'row',
        previousValue: 5,
        newValue: 6,
        timestamp: ts,
      );

      final json = action.toJson();
      final restored = CounterAction.fromJson(json);

      expect(restored.counterType, 'row');
      expect(restored.previousValue, 5);
      expect(restored.newValue, 6);
      expect(restored.counterId, isNull);
      expect(restored.timestamp.millisecondsSinceEpoch,
          ts.millisecondsSinceEpoch);
    });

    test('toJson -> fromJson 왕복 변환 (counterId 포함)', () {
      final ts = DateTime(2025, 6, 15, 10, 0, 0);
      final action = CounterAction(
        counterType: 'secondary',
        previousValue: 3,
        newValue: 4,
        counterId: 42,
        timestamp: ts,
      );

      final json = action.toJson();
      expect(json.containsKey('cid'), true);

      final restored = CounterAction.fromJson(json);
      expect(restored.counterType, 'secondary');
      expect(restored.counterId, 42);
    });

    test('counterId가 null이면 JSON에 cid 키 없음', () {
      final action = CounterAction(
        counterType: 'row',
        previousValue: 0,
        newValue: 1,
      );

      final json = action.toJson();
      expect(json.containsKey('cid'), false);
    });
  });

  group('Project - counterHistory 캐싱', () {
    test('빈 JSON은 빈 리스트 반환', () {
      final project = createTestProject(counterHistoryJson: '[]');
      expect(project.counterHistory, isEmpty);
    });

    test('유효한 JSON은 올바른 리스트 반환', () {
      final actions = [
        CounterAction(
          counterType: 'row',
          previousValue: 0,
          newValue: 1,
          timestamp: fixedNow,
        ),
        CounterAction(
          counterType: 'stitch',
          previousValue: 2,
          newValue: 3,
          timestamp: fixedNow,
        ),
      ];
      final jsonStr =
          jsonEncode(actions.map((a) => a.toJson()).toList());

      final project = createTestProject(counterHistoryJson: jsonStr);
      final history = project.counterHistory;

      expect(history.length, 2);
      expect(history[0].counterType, 'row');
      expect(history[1].counterType, 'stitch');
    });

    test('잘못된 JSON은 빈 리스트 반환 (크래시 방지)', () {
      final project =
          createTestProject(counterHistoryJson: 'invalid json!!!');
      expect(project.counterHistory, isEmpty);
    });

    test('setter 사용 시 JSON 직렬화 (dirty flag)', () {
      final project = createTestProject();
      final newHistory = [
        CounterAction(
          counterType: 'row',
          previousValue: 0,
          newValue: 1,
          timestamp: fixedNow,
        ),
      ];

      project.counterHistory = newHistory;

      // JSON이 업데이트되었는지 확인
      final decoded = jsonDecode(project.counterHistoryJson) as List;
      expect(decoded.length, 1);
      expect(decoded[0]['type'], 'row');
    });

    test('addCounterAction 50개 초과 시 가장 오래된 항목 제거', () {
      final project = createTestProject();

      // 51개 추가
      for (int i = 0; i < 51; i++) {
        project.addCounterAction('row', i, i + 1);
      }

      expect(project.counterHistory.length, 50);
      // 첫 번째 항목이 제거되었으므로 두 번째가 첫 번째가 됨
      expect(project.counterHistory.first.previousValue, 1);
    });

    test('popCounterAction 정상 동작', () {
      final project = createTestProject();
      project.addCounterAction('row', 0, 1);
      project.addCounterAction('row', 1, 2);

      final popped = project.popCounterAction();
      expect(popped, isNotNull);
      expect(popped!.previousValue, 1);
      expect(popped.newValue, 2);
      expect(project.counterHistory.length, 1);
    });

    test('popCounterAction 빈 리스트에서 null 반환', () {
      final project = createTestProject();
      expect(project.popCounterAction(), isNull);
    });
  });

  group('Project - getters (rowCounter 기반)', () {
    test('currentRow는 rowCounter의 value 반환', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 15),
      );
      expect(project.currentRow, 15);
    });

    test('rowCounter 없으면 currentRow는 0', () {
      final project = createTestProject();
      expect(project.currentRow, 0);
    });

    test('targetRow는 rowCounter의 targetValue 반환', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1, targetRow: 100),
      );
      expect(project.targetRow, 100);
    });

    test('targetRow가 없으면 null 반환', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
      );
      expect(project.targetRow, isNull);
    });

    test('progress는 rowCounter의 progress 반환', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 50, targetRow: 100),
      );
      expect(project.progress, 0.5);
    });

    test('status는 statusIndex에 따라 결정', () {
      final inProgress = createTestProject(statusIndex: 0);
      expect(inProgress.status, ProjectStatus.inProgress);

      final completed = createTestProject(id: 2, statusIndex: 1);
      expect(completed.status, ProjectStatus.completed);

      final paused = createTestProject(id: 3, statusIndex: 2);
      expect(paused.status, ProjectStatus.paused);
    });
  });

  group('Project - incrementRow / decrementRow', () {
    test('incrementRow시 value 증가 및 히스토리 추가', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 5),
      );

      project.incrementRow();

      expect(project.rowCounter.target!.value, 6);
      expect(project.counterHistory.length, 1);
      expect(project.counterHistory.first.counterType, 'row');
      expect(project.counterHistory.first.previousValue, 5);
      expect(project.counterHistory.first.newValue, 6);
    });

    test('incrementRow시 연동된 보조 카운터도 증가', () {
      final secondary = Counter.secondaryRepetition(
        id: 2,
        label: '연동',
        resetAt: 4,
      );
      secondary.isLinked = true;

      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 0),
        secondaryCounters: [secondary],
      );

      project.incrementRow();

      expect(project.rowCounter.target!.value, 1);
      expect(project.secondaryCounters.first.value, 1);
    });

    test('decrementRow시 value 감소', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 5),
      );

      project.decrementRow();

      expect(project.rowCounter.target!.value, 4);
    });

    test('decrementRow시 value가 0이면 변경 없음', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 0),
      );

      project.decrementRow();

      expect(project.rowCounter.target!.value, 0);
      // 히스토리도 추가되지 않음
      expect(project.counterHistory, isEmpty);
    });

    test('decrementRow시 연동된 보조 카운터도 감소', () {
      final secondary = Counter.secondaryGoal(
        id: 2,
        label: '연동목표',
        targetValue: 10,
      );
      secondary.isLinked = true;
      secondary.value = 3;

      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 5),
        secondaryCounters: [secondary],
      );

      project.decrementRow();

      expect(project.secondaryCounters.first.value, 2);
    });
  });

  group('Project - undo', () {
    test('row 카운터 undo', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1, initialValue: 0),
      );

      project.incrementRow();
      expect(project.rowCounter.target!.value, 1);

      final result = project.undo();
      expect(result, true);
      expect(project.rowCounter.target!.value, 0);
    });

    test('stitch 카운터 undo', () {
      final project = createTestProject(
        stitchCounter: Counter.stitch(id: 2, initialValue: 0),
      );

      project.incrementStitch();
      expect(project.stitchCounter.target!.value, 1);

      final result = project.undo();
      expect(result, true);
      expect(project.stitchCounter.target!.value, 0);
    });

    test('pattern 카운터 undo', () {
      final project = createTestProject(
        patternCounter: Counter.pattern(id: 3, initialValue: 0),
      );

      project.incrementPattern();
      expect(project.patternCounter.target!.value, 1);

      final result = project.undo();
      expect(result, true);
      expect(project.patternCounter.target!.value, 0);
    });

    test('secondary 카운터 undo', () {
      final secondary = Counter.secondaryGoal(
        id: 4,
        label: '목표',
        targetValue: 10,
      );

      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
        secondaryCounters: [secondary],
      );

      project.incrementSecondaryCounter(4);
      expect(project.secondaryCounters.first.value, 1);

      final result = project.undo();
      expect(result, true);
      expect(project.secondaryCounters.first.value, 0);
    });

    test('빈 히스토리에서 undo는 false 반환', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
      );
      expect(project.undo(), false);
    });
  });

  group('Project - incrementSecondaryCounter', () {
    test('반복 유형: 자동 리셋 발생 시 (true, false) 반환', () {
      final secondary = Counter.secondaryRepetition(
        id: 2,
        label: '반복',
        resetAt: 3,
      );
      secondary.value = 2; // resetAt=3에 도달하면 리셋

      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
        secondaryCounters: [secondary],
      );

      final (didAutoReset, isGoalReached) =
          project.incrementSecondaryCounter(2);

      expect(didAutoReset, true);
      expect(isGoalReached, false);
      expect(project.secondaryCounters.first.value, 0);
    });

    test('횟수 유형: 목표 달성 시 (false, true) 반환', () {
      final secondary = Counter.secondaryGoal(
        id: 2,
        label: '목표',
        targetValue: 3,
      );
      secondary.value = 2;

      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
        secondaryCounters: [secondary],
      );

      final (didAutoReset, isGoalReached) =
          project.incrementSecondaryCounter(2);

      expect(didAutoReset, false);
      expect(isGoalReached, true);
      expect(project.secondaryCounters.first.value, 3);
    });

    test('일반 증가 시 (false, false) 반환', () {
      final secondary = Counter.secondaryGoal(
        id: 2,
        label: '목표',
        targetValue: 10,
      );

      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
        secondaryCounters: [secondary],
      );

      final (didAutoReset, isGoalReached) =
          project.incrementSecondaryCounter(2);

      expect(didAutoReset, false);
      expect(isGoalReached, false);
      expect(project.secondaryCounters.first.value, 1);
    });

    test('존재하지 않는 카운터 ID는 (false, false) 반환', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
      );

      final (didAutoReset, isGoalReached) =
          project.incrementSecondaryCounter(999);

      expect(didAutoReset, false);
      expect(isGoalReached, false);
    });
  });

  group('Project - setCompletedDate', () {
    test('non-null 설정 시 status가 completed로 변경', () {
      final project = createTestProject(
        rowCounter: Counter.row(id: 1),
      );
      expect(project.status, ProjectStatus.inProgress);

      project.setCompletedDate(DateTime(2025, 7, 1));

      expect(project.status, ProjectStatus.completed);
      expect(project.completedDate, DateTime(2025, 7, 1));
    });

    test('null 설정 시 status가 inProgress로 변경', () {
      final project = createTestProject(
        statusIndex: ProjectStatus.completed.index,
      );
      project.completedDate = DateTime(2025, 7, 1);

      project.setCompletedDate(null);

      expect(project.status, ProjectStatus.inProgress);
      expect(project.completedDate, isNull);
    });
  });

  group('Project - resetWorkTime', () {
    test('timerStartedAt과 totalWorkSeconds 초기화', () {
      final project = createTestProject(
        totalWorkSeconds: 3600,
        timerStartedAt: fixedNow,
      );

      project.resetWorkTime();

      expect(project.timerStartedAt, isNull);
      expect(project.totalWorkSeconds, 0);
    });
  });
}
