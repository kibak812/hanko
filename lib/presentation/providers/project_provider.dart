import 'dart:ui' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/counter.dart';
import '../../data/models/models.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/datasources/local_storage.dart';
import 'app_providers.dart';

/// 보조 카운터 상태
class SecondaryCounterState {
  final int id;
  final String label;
  final SecondaryCounterType type;
  final int value;
  final int? targetValue; // goal 타입
  final int? resetAt; // repetition 타입
  final double progress;
  final bool isCompleted;
  final int orderIndex;
  final bool isLinked; // 메인 카운터 연동 여부

  SecondaryCounterState({
    required this.id,
    required this.label,
    required this.type,
    required this.value,
    this.targetValue,
    this.resetAt,
    this.progress = 0.0,
    this.isCompleted = false,
    this.orderIndex = 0,
    this.isLinked = false,
  });

  factory SecondaryCounterState.fromCounter(Counter counter) {
    return SecondaryCounterState(
      id: counter.id,
      label: counter.label,
      type: counter.secondaryType,
      value: counter.value,
      targetValue: counter.targetValue,
      resetAt: counter.resetAt,
      progress: counter.progress,
      isCompleted: counter.isCompleted,
      orderIndex: counter.orderIndex,
      isLinked: counter.isLinked,
    );
  }
}

/// 모든 프로젝트 목록 Provider
final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectsNotifier(repository);
});

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _repository;

  ProjectsNotifier(this._repository) : super(_repository.getAllProjects());

  void refresh() {
    state = _repository.getAllProjects();
  }

  Project createProject({
    required String name,
    int? targetRow,
    bool includeStitchCounter = false,
    bool includePatternCounter = false,
    int? stitchTarget,
    int? patternResetAt,
  }) {
    final project = _repository.createProject(
      name: name,
      targetRow: targetRow,
      includeStitchCounter: includeStitchCounter,
      includePatternCounter: includePatternCounter,
      stitchTarget: stitchTarget,
      patternResetAt: patternResetAt,
    );
    refresh();
    return project;
  }

  /// 코 카운터 추가
  void addStitchCounter(Project project, {int? targetValue}) {
    _repository.addStitchCounter(project, targetValue: targetValue);
    refresh();
  }

  /// 패턴 카운터 추가
  void addPatternCounter(Project project, {int? resetAt}) {
    _repository.addPatternCounter(project, resetAt: resetAt);
    refresh();
  }

  /// 코 카운터 제거
  void removeStitchCounter(Project project) {
    _repository.removeStitchCounter(project);
    refresh();
  }

  /// 패턴 카운터 제거
  void removePatternCounter(Project project) {
    _repository.removePatternCounter(project);
    refresh();
  }

  /// 코 카운터 설정 업데이트
  void updateStitchCounter(Project project, {int? targetValue}) {
    _repository.updateStitchCounter(project, targetValue: targetValue);
    refresh();
  }

  /// 패턴 카운터 설정 업데이트
  void updatePatternCounter(Project project, {int? resetAt}) {
    _repository.updatePatternCounter(project, resetAt: resetAt);
    refresh();
  }

  // ============ 동적 보조 카운터 관리 ============

  /// 보조 카운터 추가 가능 여부
  bool canAddSecondaryCounter(Project project, {required bool isPremium}) {
    return _repository.canAddSecondaryCounter(project, isPremium: isPremium);
  }

  /// 보조 카운터 추가 (반복 유형)
  Counter addSecondaryRepetitionCounter(
    Project project, {
    required String label,
    int? resetAt,
  }) {
    final counter = _repository.addSecondaryRepetitionCounter(
      project,
      label: label,
      resetAt: resetAt,
    );
    refresh();
    return counter;
  }

  /// 보조 카운터 추가 (횟수 유형)
  Counter addSecondaryGoalCounter(
    Project project, {
    required String label,
    int? targetValue,
  }) {
    final counter = _repository.addSecondaryGoalCounter(
      project,
      label: label,
      targetValue: targetValue,
    );
    refresh();
    return counter;
  }

  /// 보조 카운터 제거
  void removeSecondaryCounter(Project project, int counterId) {
    _repository.removeSecondaryCounter(project, counterId);
    refresh();
  }

  /// 보조 카운터 설정 업데이트
  void updateSecondaryCounter(
    Project project,
    int counterId, {
    String? label,
    int? targetValue,
    int? resetAt,
    SecondaryCounterType? type,
  }) {
    _repository.updateSecondaryCounter(
      project,
      counterId,
      label: label,
      targetValue: targetValue,
      resetAt: resetAt,
      type: type,
    );
    refresh();
  }

  /// 보조 카운터 연동 토글
  void toggleSecondaryCounterLink(Project project, int counterId) {
    _repository.toggleSecondaryCounterLink(project, counterId);
    refresh();
  }

  void deleteProject(int id) {
    _repository.deleteProject(id);
    refresh();
  }

  void renameProject(Project project, String newName) {
    _repository.renameProject(project, newName);
    refresh();
  }

  void updateProject(int projectId, {String? name, int? targetRow}) {
    final project = state.firstWhere((p) => p.id == projectId);
    _repository.updateProject(project, name: name, targetRow: targetRow);
    refresh();
  }

  void completeProject(Project project) {
    _repository.completeProject(project);
    refresh();
  }
}

/// 활성 프로젝트 ID Provider
final activeProjectIdProvider = StateNotifierProvider<ActiveProjectIdNotifier, int?>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return ActiveProjectIdNotifier(localStorage);
});

class ActiveProjectIdNotifier extends StateNotifier<int?> {
  final LocalStorage _localStorage;

  ActiveProjectIdNotifier(this._localStorage)
      : super(_localStorage.getActiveProjectId());

  Future<void> setActiveProject(int? id) async {
    await _localStorage.setActiveProjectId(id);
    state = id;
  }
}

/// 활성 프로젝트 Provider
final activeProjectProvider = Provider<Project?>((ref) {
  final activeId = ref.watch(activeProjectIdProvider);
  final projects = ref.watch(projectsProvider);

  if (activeId == null) {
    // 활성 프로젝트가 없으면 첫 번째 프로젝트 반환
    return projects.isEmpty ? null : projects.first;
  }

  try {
    return projects.firstWhere((p) => p.id == activeId);
  } catch (_) {
    return projects.isEmpty ? null : projects.first;
  }
});

/// 활성 프로젝트 카운터 상태 Provider
final activeProjectCounterProvider =
    StateNotifierProvider<ActiveProjectCounterNotifier, ProjectCounterState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  final activeProject = ref.watch(activeProjectProvider);
  final projectsNotifier = ref.read(projectsProvider.notifier);

  return ActiveProjectCounterNotifier(
    repository,
    activeProject,
    projectsNotifier.refresh,
  );
});

/// 프로젝트 카운터 상태
class ProjectCounterState {
  final int currentRow;
  final int? targetRow;
  final int currentStitch;
  final int currentPattern;
  final bool canUndo;
  final RowMemo? currentMemo;
  final double progress;

  // 보조 카운터 상태 (레거시 호환용)
  final int? stitchTarget;
  final int? patternResetAt;
  final double stitchProgress;
  final bool hasStitchCounter;
  final bool hasPatternCounter;

  // 동적 보조 카운터 목록
  final List<SecondaryCounterState> secondaryCounters;

  // 이벤트 플래그 (피드백용)
  final bool stitchGoalReached;
  final bool patternWasReset;
  final int? goalReachedCounterId; // 목표 달성한 카운터 ID
  final int? resetTriggeredCounterId; // 자동 리셋된 카운터 ID

  // 타이머/날짜 관련
  final DateTime? startDate;
  final DateTime? completedDate;
  final int totalWorkSeconds;
  final bool isTimerRunning;
  final DateTime? timerStartedAt;

  ProjectCounterState({
    this.currentRow = 0,
    this.targetRow,
    this.currentStitch = 0,
    this.currentPattern = 0,
    this.canUndo = false,
    this.currentMemo,
    this.progress = 0.0,
    this.stitchTarget,
    this.patternResetAt,
    this.stitchProgress = 0.0,
    this.hasStitchCounter = false,
    this.hasPatternCounter = false,
    this.secondaryCounters = const [],
    this.stitchGoalReached = false,
    this.patternWasReset = false,
    this.goalReachedCounterId,
    this.resetTriggeredCounterId,
    this.startDate,
    this.completedDate,
    this.totalWorkSeconds = 0,
    this.isTimerRunning = false,
    this.timerStartedAt,
  });

  ProjectCounterState copyWith({
    int? currentRow,
    int? targetRow,
    int? currentStitch,
    int? currentPattern,
    bool? canUndo,
    RowMemo? currentMemo,
    double? progress,
    int? stitchTarget,
    int? patternResetAt,
    double? stitchProgress,
    bool? hasStitchCounter,
    bool? hasPatternCounter,
    List<SecondaryCounterState>? secondaryCounters,
    bool? stitchGoalReached,
    bool? patternWasReset,
    int? goalReachedCounterId,
    int? resetTriggeredCounterId,
    DateTime? startDate,
    DateTime? completedDate,
    int? totalWorkSeconds,
    bool? isTimerRunning,
    DateTime? timerStartedAt,
  }) {
    return ProjectCounterState(
      currentRow: currentRow ?? this.currentRow,
      targetRow: targetRow ?? this.targetRow,
      currentStitch: currentStitch ?? this.currentStitch,
      currentPattern: currentPattern ?? this.currentPattern,
      canUndo: canUndo ?? this.canUndo,
      currentMemo: currentMemo,
      progress: progress ?? this.progress,
      stitchTarget: stitchTarget ?? this.stitchTarget,
      patternResetAt: patternResetAt ?? this.patternResetAt,
      stitchProgress: stitchProgress ?? this.stitchProgress,
      hasStitchCounter: hasStitchCounter ?? this.hasStitchCounter,
      hasPatternCounter: hasPatternCounter ?? this.hasPatternCounter,
      secondaryCounters: secondaryCounters ?? this.secondaryCounters,
      stitchGoalReached: stitchGoalReached ?? this.stitchGoalReached,
      patternWasReset: patternWasReset ?? this.patternWasReset,
      goalReachedCounterId: goalReachedCounterId,
      resetTriggeredCounterId: resetTriggeredCounterId,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      totalWorkSeconds: totalWorkSeconds ?? this.totalWorkSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
    );
  }
}

class ActiveProjectCounterNotifier extends StateNotifier<ProjectCounterState> {
  final ProjectRepository _repository;
  final Project? _project;
  final VoidCallback _refreshProjects;

  ActiveProjectCounterNotifier(
    this._repository,
    this._project,
    this._refreshProjects,
  ) : super(_buildState(_project));

  static ProjectCounterState _buildState(Project? project, {
    bool stitchGoalReached = false,
    bool patternWasReset = false,
    int? goalReachedCounterId,
    int? resetTriggeredCounterId,
  }) {
    if (project == null) {
      return ProjectCounterState();
    }

    final stitchCounter = project.stitchCounter.target;
    final patternCounter = project.patternCounter.target;

    // 동적 보조 카운터 상태 빌드
    final secondaryCounterStates = project.secondaryCounters
        .map((c) => SecondaryCounterState.fromCounter(c))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return ProjectCounterState(
      currentRow: project.currentRow,
      targetRow: project.targetRow,
      currentStitch: stitchCounter?.value ?? 0,
      currentPattern: patternCounter?.value ?? 0,
      canUndo: project.canUndo,
      currentMemo: project.currentMemo,
      progress: project.progress,
      stitchTarget: stitchCounter?.targetValue,
      patternResetAt: patternCounter?.resetAt,
      stitchProgress: stitchCounter?.progress ?? 0.0,
      hasStitchCounter: stitchCounter != null,
      hasPatternCounter: patternCounter != null,
      secondaryCounters: secondaryCounterStates,
      stitchGoalReached: stitchGoalReached,
      patternWasReset: patternWasReset,
      goalReachedCounterId: goalReachedCounterId,
      resetTriggeredCounterId: resetTriggeredCounterId,
      startDate: project.startDate,
      completedDate: project.completedDate,
      totalWorkSeconds: project.totalWorkSeconds,
      isTimerRunning: project.isTimerRunning,
      timerStartedAt: project.timerStartedAt,
    );
  }

  void _updateState({
    bool stitchGoalReached = false,
    bool patternWasReset = false,
    int? goalReachedCounterId,
    int? resetTriggeredCounterId,
  }) {
    state = _buildState(
      _project,
      stitchGoalReached: stitchGoalReached,
      patternWasReset: patternWasReset,
      goalReachedCounterId: goalReachedCounterId,
      resetTriggeredCounterId: resetTriggeredCounterId,
    );
    _refreshProjects();
  }

  /// 이벤트 플래그 초기화 (피드백 표시 후 호출)
  void clearEventFlags() {
    if (state.stitchGoalReached ||
        state.patternWasReset ||
        state.goalReachedCounterId != null ||
        state.resetTriggeredCounterId != null) {
      state = state.copyWith(
        stitchGoalReached: false,
        patternWasReset: false,
        goalReachedCounterId: null,
        resetTriggeredCounterId: null,
      );
    }
  }

  /// 단 증가
  void incrementRow() {
    if (_project == null) return;
    _repository.incrementRow(_project);
    _updateState();
  }

  /// 단 감소
  void decrementRow() {
    if (_project == null) return;
    _repository.decrementRow(_project);
    _updateState();
  }

  /// 되돌리기
  bool undo() {
    if (_project == null) return false;
    final result = _repository.undoRow(_project);
    _updateState();
    return result;
  }

  /// 코 증가
  void incrementStitch() {
    if (_project == null) return;
    final stitchCounter = _project.stitchCounter.target;
    final previousValue = stitchCounter?.value ?? 0;

    _repository.incrementStitch(_project);

    // 목표 달성 체크
    final newValue = stitchCounter?.value ?? 0;
    final target = stitchCounter?.targetValue;
    final goalReached = target != null &&
        previousValue < target &&
        newValue >= target;

    _updateState(stitchGoalReached: goalReached);
  }

  /// 코 감소
  void decrementStitch() {
    if (_project == null) return;
    _repository.decrementStitch(_project);
    _updateState();
  }

  /// 코 리셋
  void resetStitch() {
    if (_project == null) return;
    _repository.resetStitch(_project);
    _updateState();
  }

  /// 패턴 증가
  void incrementPattern() {
    if (_project == null) return;
    final patternCounter = _project.patternCounter.target;
    final previousValue = patternCounter?.value ?? 0;

    _repository.incrementPattern(_project);

    // 자동 리셋 발생 체크 (값이 0으로 돌아갔으면 리셋됨)
    final newValue = patternCounter?.value ?? 0;
    final wasReset = previousValue > 0 && newValue == 0;

    _updateState(patternWasReset: wasReset);
  }

  /// 패턴 감소
  void decrementPattern() {
    if (_project == null) return;
    _repository.decrementPattern(_project);
    _updateState();
  }

  /// 패턴 리셋
  void resetPattern() {
    if (_project == null) return;
    _repository.resetPattern(_project);
    _updateState();
  }

  /// 메모 추가
  void addMemo(int rowNumber, String content) {
    if (_project == null) return;
    _repository.addMemo(_project, rowNumber, content);
    _updateState();
  }

  /// 메모 삭제
  void removeMemo(int memoId) {
    if (_project == null) return;
    _repository.removeMemo(_project, memoId);
    _updateState();
  }

  /// 메모 수정
  void updateMemo(int memoId, int rowNumber, String content) {
    if (_project == null) return;
    _repository.updateMemo(_project, memoId, rowNumber, content);
    _updateState();
  }

  // ============ 동적 보조 카운터 조작 ============

  /// 보조 카운터 증가
  void incrementSecondaryCounter(int counterId) {
    if (_project == null) return;
    final (didAutoReset, isGoalReached) =
        _repository.incrementSecondaryCounter(_project, counterId);
    _updateState(
      goalReachedCounterId: isGoalReached ? counterId : null,
      resetTriggeredCounterId: didAutoReset ? counterId : null,
    );
  }

  /// 보조 카운터 감소
  void decrementSecondaryCounter(int counterId) {
    if (_project == null) return;
    _repository.decrementSecondaryCounter(_project, counterId);
    _updateState();
  }

  /// 보조 카운터 리셋
  void resetSecondaryCounter(int counterId) {
    if (_project == null) return;
    _repository.resetSecondaryCounter(_project, counterId);
    _updateState();
  }

  /// 보조 카운터 값 직접 설정
  void setSecondaryCounterValue(int counterId, int value) {
    if (_project == null) return;
    _repository.setSecondaryCounterValue(_project, counterId, value);
    _updateState();
  }

  /// 보조 카운터 연동 토글
  void toggleSecondaryCounterLink(int counterId) {
    if (_project == null) return;
    _repository.toggleSecondaryCounterLink(_project, counterId);
    _updateState();
  }

  // ============ 타이머 조작 ============

  /// 타이머 토글 (시작/정지)
  void toggleTimer() {
    if (_project == null) return;
    _repository.toggleTimer(_project);
    _updateState();
  }

  /// 타이머 정지 (백그라운드 전환 시 사용)
  void stopTimer() {
    if (_project == null) return;
    _repository.stopTimer(_project);
    _updateState();
  }

  /// 누적 작업 시간 리셋
  void resetWorkTime() {
    if (_project == null) return;
    _repository.resetWorkTime(_project);
    _updateState();
  }

  // ============ 날짜 조작 ============

  /// 시작일 설정
  void setStartDate(DateTime? date) {
    if (_project == null) return;
    _repository.setStartDate(_project, date);
    _updateState();
  }

  /// 완료일 설정 (프로젝트 상태도 함께 변경됨)
  void setCompletedDate(DateTime? date) {
    if (_project == null) return;
    _repository.setCompletedDate(_project, date);
    _updateState();
  }
}
