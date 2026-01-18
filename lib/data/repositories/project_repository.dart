import '../datasources/objectbox_database.dart';
import '../models/models.dart';

/// 프로젝트 리포지토리
/// 프로젝트 데이터 관리를 위한 추상화 레이어
class ProjectRepository {
  final ObjectBoxDatabase _db;

  ProjectRepository(this._db);

  // ============ 프로젝트 CRUD ============

  /// 모든 프로젝트 조회
  List<Project> getAllProjects() {
    return _db.getAllProjects();
  }

  /// 프로젝트 ID로 조회
  Project? getProject(int id) {
    return _db.getProject(id);
  }

  /// 새 프로젝트 생성
  Project createProject({
    required String name,
    int? targetRow,
    bool includeStitchCounter = false,
    bool includePatternCounter = false,
    int? patternResetAt,
  }) {
    final project = Project(name: name);

    // 메인 단 카운터 생성
    final rowCounter = Counter.row(targetRow: targetRow);
    _db.counterBox.put(rowCounter);
    project.rowCounter.target = rowCounter;

    // 보조 코 카운터 (선택적)
    if (includeStitchCounter) {
      final stitchCounter = Counter.stitch();
      _db.counterBox.put(stitchCounter);
      project.stitchCounter.target = stitchCounter;
    }

    // 패턴 반복 카운터 (선택적)
    if (includePatternCounter) {
      final patternCounter = Counter.pattern(
        resetAt: patternResetAt,
        autoReset: patternResetAt != null,
      );
      _db.counterBox.put(patternCounter);
      project.patternCounter.target = patternCounter;
    }

    _db.saveProject(project);
    return project;
  }

  /// 프로젝트 저장 (업데이트)
  void saveProject(Project project) {
    _db.saveProject(project);
  }

  /// 프로젝트 삭제
  bool deleteProject(int projectId) {
    return _db.deleteProject(projectId);
  }

  // ============ 카운터 연산 ============

  /// 단 증가
  void incrementRow(Project project) {
    project.incrementRow();
    _saveProjectAndCounters(project);
  }

  /// 단 감소
  void decrementRow(Project project) {
    project.decrementRow();
    _saveProjectAndCounters(project);
  }

  /// 되돌리기
  bool undoRow(Project project) {
    final success = project.undo();
    if (success) {
      _saveProjectAndCounters(project);
    }
    return success;
  }

  /// 코 증가
  void incrementStitch(Project project) {
    project.incrementStitch();
    _saveProjectAndCounters(project);
  }

  /// 코 감소
  void decrementStitch(Project project) {
    project.decrementStitch();
    _saveProjectAndCounters(project);
  }

  /// 코 리셋
  void resetStitch(Project project) {
    project.resetStitch();
    _saveProjectAndCounters(project);
  }

  /// 패턴 증가
  void incrementPattern(Project project) {
    project.incrementPattern();
    _saveProjectAndCounters(project);
  }

  /// 패턴 리셋
  void resetPattern(Project project) {
    project.resetPattern();
    _saveProjectAndCounters(project);
  }

  void _saveProjectAndCounters(Project project) {
    // 카운터들 저장
    if (project.rowCounter.target != null) {
      _db.saveCounter(project.rowCounter.target!);
    }
    if (project.stitchCounter.target != null) {
      _db.saveCounter(project.stitchCounter.target!);
    }
    if (project.patternCounter.target != null) {
      _db.saveCounter(project.patternCounter.target!);
    }
    // 프로젝트 저장
    _db.projectBox.put(project);
  }

  // ============ 메모 관련 ============

  /// 메모 추가
  void addMemo(Project project, int rowNumber, String content) {
    final memo = RowMemo(rowNumber: rowNumber, content: content);
    _db.saveMemo(memo);
    project.memos.add(memo);
    _db.saveProject(project);
  }

  /// 메모 삭제
  void removeMemo(Project project, int memoId) {
    project.memos.removeWhere((m) => m.id == memoId);
    _db.deleteMemo(memoId);
    _db.saveProject(project);
  }

  // ============ 상태 관련 ============

  /// 프로젝트 완료 처리
  void completeProject(Project project) {
    project.markAsCompleted();
    _db.saveProject(project);
  }

  /// 프로젝트 이름 변경
  void renameProject(Project project, String newName) {
    project.name = newName;
    _db.saveProject(project);
  }

  // ============ 조회 ============

  /// 진행 중인 프로젝트 목록
  List<Project> getInProgressProjects() {
    return _db.getInProgressProjects();
  }

  /// 완료된 프로젝트 목록
  List<Project> getCompletedProjects() {
    return _db.getCompletedProjects();
  }

  // ============ 제한 확인 ============

  /// 무료 사용자 프로젝트 개수 제한 (2개)
  static const int freeProjectLimit = 2;

  /// 프로젝트 생성 가능 여부 (무료 사용자)
  bool canCreateProject({required bool isPremium}) {
    if (isPremium) return true;
    return getAllProjects().length < freeProjectLimit;
  }
}
