import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/datasources/local_storage.dart';
import 'app_providers.dart';

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
  }) {
    final project = _repository.createProject(
      name: name,
      targetRow: targetRow,
      includeStitchCounter: includeStitchCounter,
      includePatternCounter: includePatternCounter,
    );
    refresh();
    return project;
  }

  void deleteProject(int id) {
    _repository.deleteProject(id);
    refresh();
  }

  void renameProject(Project project, String newName) {
    _repository.renameProject(project, newName);
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

  ProjectCounterState({
    this.currentRow = 0,
    this.targetRow,
    this.currentStitch = 0,
    this.currentPattern = 0,
    this.canUndo = false,
    this.currentMemo,
    this.progress = 0.0,
  });

  ProjectCounterState copyWith({
    int? currentRow,
    int? targetRow,
    int? currentStitch,
    int? currentPattern,
    bool? canUndo,
    RowMemo? currentMemo,
    double? progress,
  }) {
    return ProjectCounterState(
      currentRow: currentRow ?? this.currentRow,
      targetRow: targetRow ?? this.targetRow,
      currentStitch: currentStitch ?? this.currentStitch,
      currentPattern: currentPattern ?? this.currentPattern,
      canUndo: canUndo ?? this.canUndo,
      currentMemo: currentMemo,
      progress: progress ?? this.progress,
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

  static ProjectCounterState _buildState(Project? project) {
    if (project == null) {
      return ProjectCounterState();
    }

    return ProjectCounterState(
      currentRow: project.currentRow,
      targetRow: project.targetRow,
      currentStitch: project.stitchCounter.target?.value ?? 0,
      currentPattern: project.patternCounter.target?.value ?? 0,
      canUndo: project.canUndo,
      currentMemo: project.currentMemo,
      progress: project.progress,
    );
  }

  void _updateState() {
    state = _buildState(_project);
    _refreshProjects();
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
    _repository.incrementStitch(_project);
    _updateState();
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
    _repository.incrementPattern(_project);
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
}

typedef VoidCallback = void Function();
