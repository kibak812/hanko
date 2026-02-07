import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hanko_hanko/data/models/models.dart';
import 'package:hanko_hanko/presentation/providers/project_provider.dart';
import 'package:hanko_hanko/presentation/providers/app_providers.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbacks();
  });

  // ============================================================
  // ProjectCounterState.copyWith regression (agent-unit 작성분)
  // ============================================================

  group('ProjectCounterState - copyWith regression', () {
    test('currentRow만 변경 시 currentMemo는 null이 됨 (regression)', () {
      final memo = createTestMemo(id: 1, rowNumber: 5, content: '줄이기');
      final state = ProjectCounterState(
        currentRow: 3,
        currentMemo: memo,
        canUndo: true,
        progress: 0.3,
      );

      final updated = state.copyWith(currentRow: 5);

      expect(updated.currentRow, 5);
      expect(updated.currentMemo, isNull);
    });

    test('currentMemo를 명시적으로 전달하면 유지됨', () {
      final memo = createTestMemo(id: 1, rowNumber: 5, content: '줄이기');
      final state = ProjectCounterState(
        currentRow: 3,
        currentMemo: memo,
      );

      final updated = state.copyWith(
        currentRow: 5,
        currentMemo: memo,
      );

      expect(updated.currentRow, 5);
      expect(updated.currentMemo, isNotNull);
      expect(updated.currentMemo!.content, '줄이기');
    });

    test('모든 필드가 copyWith에서 올바르게 보존/변경됨', () {
      final memo = createTestMemo(id: 1, rowNumber: 10, content: '메모');
      final startDate = DateTime(2025, 1, 1);
      final completedDate = DateTime(2025, 6, 15);
      final timerStartedAt = DateTime(2025, 6, 15, 14, 0);

      final secondaryCounters = [
        SecondaryCounterState(
          id: 1,
          label: '보조',
          type: SecondaryCounterType.goal,
          value: 5,
        ),
      ];

      final state = ProjectCounterState(
        currentRow: 10,
        targetRow: 100,
        canUndo: true,
        currentMemo: memo,
        progress: 0.1,
        stitchTarget: 50,
        patternResetAt: 4,
        secondaryCounters: secondaryCounters,
        stitchGoalReached: true,
        patternWasReset: true,
        goalReachedCounterId: 1,
        resetTriggeredCounterId: 2,
        startDate: startDate,
        completedDate: completedDate,
        totalWorkSeconds: 3600,
        isTimerRunning: true,
        timerStartedAt: timerStartedAt,
      );

      final copied = state.copyWith();

      expect(copied.currentRow, 10);
      expect(copied.targetRow, 100);
      expect(copied.canUndo, true);
      expect(copied.progress, 0.1);
      expect(copied.stitchTarget, 50);
      expect(copied.patternResetAt, 4);
      expect(copied.secondaryCounters, secondaryCounters);
      expect(copied.stitchGoalReached, true);
      expect(copied.patternWasReset, true);
      expect(copied.startDate, startDate);
      expect(copied.completedDate, completedDate);
      expect(copied.totalWorkSeconds, 3600);
      expect(copied.isTimerRunning, true);
      expect(copied.timerStartedAt, timerStartedAt);

      expect(copied.currentMemo, isNull);
      expect(copied.goalReachedCounterId, isNull);
      expect(copied.resetTriggeredCounterId, isNull);
    });

    test('개별 필드 변경 시 다른 필드 영향 없음', () {
      final state = ProjectCounterState(
        currentRow: 10,
        targetRow: 100,
        canUndo: true,
        progress: 0.1,
        totalWorkSeconds: 500,
      );

      final updated = state.copyWith(totalWorkSeconds: 1000);

      expect(updated.currentRow, 10);
      expect(updated.targetRow, 100);
      expect(updated.canUndo, true);
      expect(updated.progress, 0.1);
      expect(updated.totalWorkSeconds, 1000);
    });
  });

  // ============================================================
  // ProjectsNotifier
  // ============================================================

  group('ProjectsNotifier', () {
    late MockProjectRepository mockRepo;

    setUp(() {
      mockRepo = MockProjectRepository();
    });

    ProviderContainer createContainer({List<Project>? initialProjects}) {
      when(() => mockRepo.getAllProjects())
          .thenReturn(initialProjects ?? <Project>[]);
      final container = ProviderContainer(overrides: [
        projectRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      return container;
    }

    test('초기 상태: getAllProjects()에서 로드', () {
      final projects = [
        createTestProject(id: 1, name: 'A'),
        createTestProject(id: 2, name: 'B'),
      ];
      final container = createContainer(initialProjects: projects);
      addTearDown(container.dispose);

      final state = container.read(projectsProvider);
      expect(state.length, 2);
      expect(state[0].name, 'A');
      expect(state[1].name, 'B');
    });

    test('초기 상태: 프로젝트가 없으면 빈 리스트', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(projectsProvider);
      expect(state, isEmpty);
    });

    test('refresh(): getAllProjects()에서 최신 상태 반영', () {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(projectsProvider), isEmpty);

      when(() => mockRepo.getAllProjects())
          .thenReturn([createTestProject(id: 1, name: 'New')]);

      container.read(projectsProvider.notifier).refresh();
      final state = container.read(projectsProvider);
      expect(state.length, 1);
      expect(state[0].name, 'New');
    });

    test('refreshProject(): 특정 프로젝트 업데이트', () {
      final project = createTestProject(id: 1, name: 'Original');
      final container = createContainer(initialProjects: [project]);
      addTearDown(container.dispose);

      final updated = createTestProject(id: 1, name: 'Updated');
      when(() => mockRepo.getProject(1)).thenReturn(updated);

      container.read(projectsProvider.notifier).refreshProject(1);
      final state = container.read(projectsProvider);
      expect(state.length, 1);
      expect(state[0].name, 'Updated');
    });

    test('refreshProject(): 존재하지 않는 ID면 목록에 추가', () {
      final project = createTestProject(id: 1, name: 'Existing');
      final container = createContainer(initialProjects: [project]);
      addTearDown(container.dispose);

      final newProject = createTestProject(id: 2, name: 'Added');
      when(() => mockRepo.getProject(2)).thenReturn(newProject);

      container.read(projectsProvider.notifier).refreshProject(2);
      final state = container.read(projectsProvider);
      expect(state.length, 2);
      expect(state[1].name, 'Added');
    });

    test('refreshProject(): repository가 null 반환하면 변경 없음', () {
      final project = createTestProject(id: 1, name: 'Existing');
      final container = createContainer(initialProjects: [project]);
      addTearDown(container.dispose);

      when(() => mockRepo.getProject(99)).thenReturn(null);

      container.read(projectsProvider.notifier).refreshProject(99);
      final state = container.read(projectsProvider);
      expect(state.length, 1);
    });

    test('createProject(): repository 호출 후 리스트 갱신', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final created = createTestProject(id: 1, name: 'Created');
      when(() => mockRepo.createProject(
            name: any(named: 'name'),
            targetRow: any(named: 'targetRow'),
            includeStitchCounter: any(named: 'includeStitchCounter'),
            includePatternCounter: any(named: 'includePatternCounter'),
            stitchTarget: any(named: 'stitchTarget'),
            patternResetAt: any(named: 'patternResetAt'),
          )).thenReturn(created);

      when(() => mockRepo.getAllProjects()).thenReturn([created]);

      final result = container.read(projectsProvider.notifier).createProject(
            name: 'Created',
          );
      expect(result.name, 'Created');

      final state = container.read(projectsProvider);
      expect(state.length, 1);
      expect(state[0].name, 'Created');
    });

    test('deleteProject(): repository 호출 후 리스트 갱신', () {
      final project = createTestProject(id: 1, name: 'ToDelete');
      final container = createContainer(initialProjects: [project]);
      addTearDown(container.dispose);

      when(() => mockRepo.deleteProject(1)).thenReturn(true);
      when(() => mockRepo.getAllProjects()).thenReturn([]);

      container.read(projectsProvider.notifier).deleteProject(1);

      verify(() => mockRepo.deleteProject(1)).called(1);
      expect(container.read(projectsProvider), isEmpty);
    });

    test('renameProject(): repository 호출 후 리스트 갱신', () {
      final project = createTestProject(id: 1, name: 'Old');
      final container = createContainer(initialProjects: [project]);
      addTearDown(container.dispose);

      when(() => mockRepo.renameProject(any(), any())).thenReturn(null);
      final renamed = createTestProject(id: 1, name: 'New');
      when(() => mockRepo.getAllProjects()).thenReturn([renamed]);

      container.read(projectsProvider.notifier).renameProject(project, 'New');

      verify(() => mockRepo.renameProject(project, 'New')).called(1);
      expect(container.read(projectsProvider)[0].name, 'New');
    });

    test('completeProject(): repository 호출 후 리스트 갱신', () {
      final project = createTestProject(id: 1);
      final container = createContainer(initialProjects: [project]);
      addTearDown(container.dispose);

      when(() => mockRepo.completeProject(any())).thenReturn(null);
      when(() => mockRepo.getAllProjects()).thenReturn([project]);

      container.read(projectsProvider.notifier).completeProject(project);

      verify(() => mockRepo.completeProject(project)).called(1);
    });
  });

  // ============================================================
  // ActiveProjectIdNotifier
  // ============================================================

  group('ActiveProjectIdNotifier', () {
    late MockLocalStorage mockStorage;

    setUp(() {
      mockStorage = MockLocalStorage();
    });

    test('초기 상태: localStorage에서 로드', () {
      when(() => mockStorage.getActiveProjectId()).thenReturn(42);

      final notifier = ActiveProjectIdNotifier(mockStorage);
      expect(notifier.state, 42);
    });

    test('초기 상태: 저장된 ID가 없으면 null', () {
      when(() => mockStorage.getActiveProjectId()).thenReturn(null);

      final notifier = ActiveProjectIdNotifier(mockStorage);
      expect(notifier.state, isNull);
    });

    test('setActiveProject(): 상태 업데이트 및 localStorage 저장', () async {
      when(() => mockStorage.getActiveProjectId()).thenReturn(null);
      when(() => mockStorage.setActiveProjectId(any()))
          .thenAnswer((_) async => true);

      final notifier = ActiveProjectIdNotifier(mockStorage);
      await notifier.setActiveProject(10);

      expect(notifier.state, 10);
      verify(() => mockStorage.setActiveProjectId(10)).called(1);
    });

    test('setActiveProject(null): 활성 프로젝트 해제', () async {
      when(() => mockStorage.getActiveProjectId()).thenReturn(5);
      when(() => mockStorage.setActiveProjectId(any()))
          .thenAnswer((_) async => true);

      final notifier = ActiveProjectIdNotifier(mockStorage);
      await notifier.setActiveProject(null);

      expect(notifier.state, isNull);
      verify(() => mockStorage.setActiveProjectId(null)).called(1);
    });
  });

  // ============================================================
  // ActiveProjectCounterNotifier
  // ============================================================

  group('ActiveProjectCounterNotifier', () {
    late MockProjectRepository mockRepo;

    setUp(() {
      mockRepo = MockProjectRepository();
    });

    group('_buildState', () {
      test('project가 null이면 기본 ProjectCounterState 반환', () {
        final notifier = ActiveProjectCounterNotifier(mockRepo, null, (_) {});
        final state = notifier.state;

        expect(state.currentRow, 0);
        expect(state.targetRow, isNull);
        expect(state.canUndo, false);
        expect(state.currentMemo, isNull);
        expect(state.progress, 0.0);
        expect(state.secondaryCounters, isEmpty);
        expect(state.stitchGoalReached, false);
        expect(state.patternWasReset, false);
      });

      test('project가 있으면 필드를 올바르게 매핑', () {
        final rowCounter = Counter.row(id: 1, initialValue: 5, targetRow: 10);
        final stitchCounter = Counter.stitch(id: 2, targetValue: 20);
        final patternCounter =
            Counter.pattern(id: 3, resetAt: 4, autoReset: true);
        final memo = createTestMemo(id: 1, rowNumber: 5, content: 'Test memo');

        final project = createTestProject(
          id: 1,
          name: 'Test',
          rowCounter: rowCounter,
          stitchCounter: stitchCounter,
          patternCounter: patternCounter,
          memos: [memo],
          startDate: fixedNow,
          totalWorkSeconds: 3600,
          counterHistoryJson:
              '[{"type":"row","prev":4,"new":5,"ts":1718451000000}]',
        );

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        final state = notifier.state;

        expect(state.currentRow, 5);
        expect(state.targetRow, 10);
        expect(state.canUndo, true);
        expect(state.progress, 0.5);
        expect(state.stitchTarget, 20);
        expect(state.patternResetAt, 4);
        expect(state.startDate, fixedNow);
        expect(state.totalWorkSeconds, 3600);
        expect(state.stitchGoalReached, false);
        expect(state.patternWasReset, false);
      });

      test('보조 카운터들이 orderIndex 순으로 정렬됨', () {
        final sc1 = Counter.secondaryGoal(
          id: 10,
          label: 'Second',
          orderIndex: 1,
        );
        final sc2 = Counter.secondaryRepetition(
          id: 11,
          label: 'First',
          orderIndex: 0,
        );
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          secondaryCounters: [sc1, sc2],
        );

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        final state = notifier.state;

        expect(state.secondaryCounters.length, 2);
        expect(state.secondaryCounters[0].label, 'First');
        expect(state.secondaryCounters[1].label, 'Second');
      });

      test('현재 단에 해당하는 메모가 currentMemo로 매핑됨', () {
        final rowCounter = Counter.row(id: 1, initialValue: 3);
        final memo =
            createTestMemo(id: 1, rowNumber: 3, content: 'Row 3 memo');

        final project = createTestProject(
          id: 1,
          rowCounter: rowCounter,
          memos: [memo],
        );

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});

        expect(notifier.state.currentMemo, isNotNull);
        expect(notifier.state.currentMemo!.content, 'Row 3 memo');
      });
    });

    group('incrementRow', () {
      test('project가 null이면 아무 동작 안 함', () {
        final notifier = ActiveProjectCounterNotifier(mockRepo, null, (_) {});
        notifier.incrementRow();
        verifyNever(() => mockRepo.incrementRow(any()));
      });

      test('repository.incrementRow 호출 후 상태 갱신', () {
        final rowCounter = Counter.row(id: 1, initialValue: 0);
        final project = createTestProject(id: 1, rowCounter: rowCounter);

        when(() => mockRepo.incrementRow(any())).thenAnswer((_) {
          project.incrementRow();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        expect(notifier.state.currentRow, 0);

        notifier.incrementRow();

        verify(() => mockRepo.incrementRow(project)).called(1);
        expect(notifier.state.currentRow, 1);
        expect(notifier.state.canUndo, true);
      });
    });

    group('decrementRow', () {
      test('project가 null이면 아무 동작 안 함', () {
        final notifier = ActiveProjectCounterNotifier(mockRepo, null, (_) {});
        notifier.decrementRow();
        verifyNever(() => mockRepo.decrementRow(any()));
      });

      test('repository.decrementRow 호출 후 상태 갱신', () {
        final rowCounter = Counter.row(id: 1, initialValue: 5);
        final project = createTestProject(
          id: 1,
          rowCounter: rowCounter,
          counterHistoryJson:
              '[{"type":"row","prev":4,"new":5,"ts":1718451000000}]',
        );

        when(() => mockRepo.decrementRow(any())).thenAnswer((_) {
          project.decrementRow();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});

        notifier.decrementRow();

        verify(() => mockRepo.decrementRow(project)).called(1);
        expect(notifier.state.currentRow, 4);
      });
    });

    group('undo', () {
      test('project가 null이면 false 반환', () {
        final notifier = ActiveProjectCounterNotifier(mockRepo, null, (_) {});
        expect(notifier.undo(), false);
      });

      test('repository.undoRow 호출 후 결과 반환', () {
        final rowCounter = Counter.row(id: 1, initialValue: 5);
        final project = createTestProject(
          id: 1,
          rowCounter: rowCounter,
          counterHistoryJson:
              '[{"type":"row","prev":4,"new":5,"ts":1718451000000}]',
        );

        when(() => mockRepo.undoRow(any())).thenAnswer((_) {
          return project.undo();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        final result = notifier.undo();

        expect(result, true);
        expect(notifier.state.currentRow, 4);
        expect(notifier.state.canUndo, false);
      });
    });

    group('incrementStitch', () {
      test('project가 null이면 아무 동작 안 함', () {
        final notifier = ActiveProjectCounterNotifier(mockRepo, null, (_) {});
        notifier.incrementStitch();
        verifyNever(() => mockRepo.incrementStitch(any()));
      });

      test('목표 미달성시 stitchGoalReached=false', () {
        final stitchCounter =
            Counter.stitch(id: 2, initialValue: 0, targetValue: 10);
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          stitchCounter: stitchCounter,
        );

        when(() => mockRepo.incrementStitch(any())).thenAnswer((_) {
          project.incrementStitch();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.incrementStitch();

        expect(notifier.state.stitchGoalReached, false);
      });

      test('목표 달성시 stitchGoalReached=true', () {
        final stitchCounter =
            Counter.stitch(id: 2, initialValue: 9, targetValue: 10);
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          stitchCounter: stitchCounter,
        );

        when(() => mockRepo.incrementStitch(any())).thenAnswer((_) {
          project.incrementStitch();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.incrementStitch();

        expect(notifier.state.stitchGoalReached, true);
      });
    });

    group('incrementPattern', () {
      test('project가 null이면 아무 동작 안 함', () {
        final notifier = ActiveProjectCounterNotifier(mockRepo, null, (_) {});
        notifier.incrementPattern();
        verifyNever(() => mockRepo.incrementPattern(any()));
      });

      test('자동 리셋 미발생시 patternWasReset=false', () {
        final patternCounter = Counter.pattern(
            id: 3, initialValue: 0, resetAt: 4, autoReset: true);
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          patternCounter: patternCounter,
        );

        when(() => mockRepo.incrementPattern(any())).thenAnswer((_) {
          project.incrementPattern();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.incrementPattern();

        expect(notifier.state.patternWasReset, false);
      });

      test('자동 리셋 발생시 patternWasReset=true', () {
        final patternCounter = Counter.pattern(
            id: 3, initialValue: 3, resetAt: 4, autoReset: true);
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          patternCounter: patternCounter,
        );

        when(() => mockRepo.incrementPattern(any())).thenAnswer((_) {
          project.incrementPattern();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.incrementPattern();

        expect(notifier.state.patternWasReset, true);
      });
    });

    group('clearEventFlags', () {
      test('이벤트 플래그들이 초기화됨', () {
        final stitchCounter =
            Counter.stitch(id: 2, initialValue: 9, targetValue: 10);
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          stitchCounter: stitchCounter,
        );

        when(() => mockRepo.incrementStitch(any())).thenAnswer((_) {
          project.incrementStitch();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});

        notifier.incrementStitch();
        expect(notifier.state.stitchGoalReached, true);

        notifier.clearEventFlags();
        expect(notifier.state.stitchGoalReached, false);
        expect(notifier.state.patternWasReset, false);
        expect(notifier.state.goalReachedCounterId, isNull);
        expect(notifier.state.resetTriggeredCounterId, isNull);
      });

      test('플래그가 모두 false이면 상태 변경 없음', () {
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
        );

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        final stateBefore = notifier.state;

        notifier.clearEventFlags();

        expect(identical(notifier.state, stateBefore), true);
      });
    });

    group('incrementSecondaryCounter', () {
      test('목표 달성시 goalReachedCounterId 설정', () {
        final sc = Counter.secondaryGoal(
          id: 10,
          label: 'Goal',
          initialValue: 4,
          targetValue: 5,
        );
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          secondaryCounters: [sc],
        );

        when(() => mockRepo.incrementSecondaryCounter(any(), any()))
            .thenAnswer((_) {
          return project.incrementSecondaryCounter(10);
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.incrementSecondaryCounter(10);

        expect(notifier.state.goalReachedCounterId, 10);
      });

      test('자동 리셋시 resetTriggeredCounterId 설정', () {
        final sc = Counter.secondaryRepetition(
          id: 11,
          label: 'Rep',
          initialValue: 2,
          resetAt: 3,
        );
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          secondaryCounters: [sc],
        );

        when(() => mockRepo.incrementSecondaryCounter(any(), any()))
            .thenAnswer((_) {
          return project.incrementSecondaryCounter(11);
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.incrementSecondaryCounter(11);

        expect(notifier.state.resetTriggeredCounterId, 11);
      });
    });

    group('타이머 조작', () {
      test('toggleTimer: repository 호출 후 상태 갱신', () {
        final project =
            createTestProject(id: 1, rowCounter: Counter.row(id: 1));

        when(() => mockRepo.toggleTimer(any())).thenAnswer((_) {
          project.toggleTimer();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.toggleTimer();

        verify(() => mockRepo.toggleTimer(project)).called(1);
        expect(notifier.state.isTimerRunning, true);
      });

      test('stopTimer: repository 호출 후 상태 갱신', () {
        final project = createTestProject(
          id: 1,
          rowCounter: Counter.row(id: 1),
          timerStartedAt: fixedNow,
        );

        when(() => mockRepo.stopTimer(any())).thenAnswer((_) {
          project.stopTimer();
        });

        final notifier =
            ActiveProjectCounterNotifier(mockRepo, project, (_) {});
        notifier.stopTimer();

        verify(() => mockRepo.stopTimer(project)).called(1);
        expect(notifier.state.isTimerRunning, false);
      });
    });

    group('메모 조작', () {
      test('addMemo: repository 호출 및 refreshProject 콜백', () {
        final project =
            createTestProject(id: 1, rowCounter: Counter.row(id: 1));
        var refreshedId = -1;

        when(() => mockRepo.addMemo(any(), any(), any())).thenReturn(null);

        final notifier = ActiveProjectCounterNotifier(
          mockRepo,
          project,
          (id) => refreshedId = id,
        );
        notifier.addMemo(5, 'Test memo');

        verify(() => mockRepo.addMemo(project, 5, 'Test memo')).called(1);
        expect(refreshedId, 1);
      });

      test('removeMemo: repository 호출 및 refreshProject 콜백', () {
        final project =
            createTestProject(id: 1, rowCounter: Counter.row(id: 1));
        var refreshedId = -1;

        when(() => mockRepo.removeMemo(any(), any())).thenReturn(null);

        final notifier = ActiveProjectCounterNotifier(
          mockRepo,
          project,
          (id) => refreshedId = id,
        );
        notifier.removeMemo(99);

        verify(() => mockRepo.removeMemo(project, 99)).called(1);
        expect(refreshedId, 1);
      });
    });
  });

  // ============================================================
  // SecondaryCounterState
  // ============================================================

  group('SecondaryCounterState', () {
    test('fromCounter: goal 타입 매핑', () {
      final counter = Counter.secondaryGoal(
        id: 10,
        label: 'Test Goal',
        initialValue: 3,
        targetValue: 10,
        orderIndex: 2,
      );

      final state = SecondaryCounterState.fromCounter(counter);

      expect(state.id, 10);
      expect(state.label, 'Test Goal');
      expect(state.type, SecondaryCounterType.goal);
      expect(state.value, 3);
      expect(state.targetValue, 10);
      expect(state.progress, 0.3);
      expect(state.isCompleted, false);
      expect(state.orderIndex, 2);
    });

    test('fromCounter: repetition 타입 매핑', () {
      final counter = Counter.secondaryRepetition(
        id: 11,
        label: 'Test Rep',
        initialValue: 1,
        resetAt: 4,
        orderIndex: 0,
      );

      final state = SecondaryCounterState.fromCounter(counter);

      expect(state.id, 11);
      expect(state.label, 'Test Rep');
      expect(state.type, SecondaryCounterType.repetition);
      expect(state.value, 1);
      expect(state.resetAt, 4);
      expect(state.orderIndex, 0);
    });
  });
}
