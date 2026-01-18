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
    int? stitchTarget,
    int? patternResetAt,
  }) {
    final project = Project(name: name);

    // 메인 단 카운터 생성
    final rowCounter = Counter.row(targetRow: targetRow);
    _db.counterBox.put(rowCounter);
    project.rowCounter.target = rowCounter;

    // 보조 코 카운터 (선택적)
    if (includeStitchCounter) {
      final stitchCounter = Counter.stitch(targetValue: stitchTarget);
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

  /// 패턴 감소
  void decrementPattern(Project project) {
    project.decrementPattern();
    _saveProjectAndCounters(project);
  }

  /// 패턴 리셋
  void resetPattern(Project project) {
    project.resetPattern();
    _saveProjectAndCounters(project);
  }

  // ============ 보조 카운터 관리 ============

  /// 코 카운터 추가
  void addStitchCounter(Project project, {int? targetValue}) {
    if (project.stitchCounter.target != null) return; // 이미 있음
    final stitchCounter = Counter.stitch(targetValue: targetValue);
    _db.counterBox.put(stitchCounter);
    project.stitchCounter.target = stitchCounter;
    _db.saveProject(project);
  }

  /// 패턴 카운터 추가
  void addPatternCounter(Project project, {int? resetAt}) {
    if (project.patternCounter.target != null) return; // 이미 있음
    final patternCounter = Counter.pattern(
      resetAt: resetAt,
      autoReset: resetAt != null,
    );
    _db.counterBox.put(patternCounter);
    project.patternCounter.target = patternCounter;
    _db.saveProject(project);
  }

  /// 코 카운터 제거
  void removeStitchCounter(Project project) {
    final counter = project.stitchCounter.target;
    if (counter == null) return;
    project.stitchCounter.target = null;
    _db.counterBox.remove(counter.id);
    _db.saveProject(project);
  }

  /// 패턴 카운터 제거
  void removePatternCounter(Project project) {
    final counter = project.patternCounter.target;
    if (counter == null) return;
    project.patternCounter.target = null;
    _db.counterBox.remove(counter.id);
    _db.saveProject(project);
  }

  /// 코 카운터 설정 업데이트
  void updateStitchCounter(Project project, {int? targetValue}) {
    final counter = project.stitchCounter.target;
    if (counter == null) return;
    counter.targetValue = targetValue;
    _db.saveCounter(counter);
  }

  /// 패턴 카운터 설정 업데이트
  void updatePatternCounter(Project project, {int? resetAt}) {
    final counter = project.patternCounter.target;
    if (counter == null) return;
    counter.resetAt = resetAt;
    counter.autoResetEnabled = resetAt != null;
    _db.saveCounter(counter);
  }

  // ============ 동적 보조 카운터 관리 ============

  /// 무료 사용자 보조 카운터 제한 (개발용: 999)
  static const int freeSecondaryCounterLimit = 999;

  /// 보조 카운터 추가 가능 여부
  bool canAddSecondaryCounter(Project project, {required bool isPremium}) {
    if (isPremium) return true;
    return project.secondaryCounters.length < freeSecondaryCounterLimit;
  }

  /// 보조 카운터 추가 (반복 유형)
  Counter addSecondaryRepetitionCounter(
    Project project, {
    required String label,
    int? resetAt,
  }) {
    final orderIndex = project.secondaryCounters.length;
    final counter = Counter.secondaryRepetition(
      label: label,
      resetAt: resetAt,
      orderIndex: orderIndex,
    );
    _db.counterBox.put(counter);
    project.secondaryCounters.add(counter);
    _db.saveProject(project);
    return counter;
  }

  /// 보조 카운터 추가 (횟수 유형)
  Counter addSecondaryGoalCounter(
    Project project, {
    required String label,
    int? targetValue,
  }) {
    final orderIndex = project.secondaryCounters.length;
    final counter = Counter.secondaryGoal(
      label: label,
      targetValue: targetValue,
      orderIndex: orderIndex,
    );
    _db.counterBox.put(counter);
    project.secondaryCounters.add(counter);
    _db.saveProject(project);
    return counter;
  }

  /// 보조 카운터 제거
  void removeSecondaryCounter(Project project, int counterId) {
    final counter = project.getSecondaryCounter(counterId);
    if (counter == null) return;
    project.secondaryCounters.removeWhere((c) => c.id == counterId);
    _db.saveProject(project); // 먼저 관계 업데이트
    _db.counterBox.remove(counterId); // 그 다음 counter 삭제
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
    final counter = project.getSecondaryCounter(counterId);
    if (counter == null) return;
    if (label != null) counter.label = label;

    // 타입 변경 처리
    if (type != null && counter.secondaryType != type) {
      counter.secondaryType = type;
      // 타입 변경 시 해당 타입에 맞게 필드 정리
      if (type == SecondaryCounterType.goal) {
        // goal 타입: resetAt 비우고 targetValue 설정
        counter.resetAt = null;
        counter.autoResetEnabled = false;
        if (targetValue != null) counter.targetValue = targetValue;
      } else {
        // repetition 타입: targetValue 비우고 resetAt 설정
        counter.targetValue = null;
        if (resetAt != null) {
          counter.resetAt = resetAt;
          counter.autoResetEnabled = true;
        }
      }
    } else {
      // 타입 변경 없이 값만 업데이트
      if (targetValue != null) counter.targetValue = targetValue;
      if (resetAt != null) {
        counter.resetAt = resetAt;
        counter.autoResetEnabled = true;
      }
    }

    _db.saveCounter(counter);
  }

  /// 보조 카운터 증가
  (bool, bool) incrementSecondaryCounter(Project project, int counterId) {
    final result = project.incrementSecondaryCounter(counterId);
    _saveProjectAndCounters(project);
    return result;
  }

  /// 보조 카운터 감소
  void decrementSecondaryCounter(Project project, int counterId) {
    project.decrementSecondaryCounter(counterId);
    _saveProjectAndCounters(project);
  }

  /// 보조 카운터 리셋
  void resetSecondaryCounter(Project project, int counterId) {
    project.resetSecondaryCounter(counterId);
    _saveProjectAndCounters(project);
  }

  /// 보조 카운터 값 직접 설정
  void setSecondaryCounterValue(Project project, int counterId, int value) {
    project.setSecondaryCounterValue(counterId, value);
    _saveProjectAndCounters(project);
  }

  /// 보조 카운터 연동 토글
  void toggleSecondaryCounterLink(Project project, int counterId) {
    final counter = project.getSecondaryCounter(counterId);
    if (counter == null) return;
    counter.isLinked = !counter.isLinked;
    _db.saveCounter(counter);
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
    // 보조 카운터들 저장
    for (final counter in project.secondaryCounters) {
      _db.saveCounter(counter);
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

  /// 메모 수정
  void updateMemo(Project project, int memoId, int rowNumber, String content) {
    final memoIndex = project.memos.indexWhere((m) => m.id == memoId);
    if (memoIndex != -1) {
      final memo = project.memos[memoIndex];
      memo.rowNumber = rowNumber;
      memo.content = content;
      _db.saveMemo(memo);
      _db.saveProject(project);
    }
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

  /// 프로젝트 정보 업데이트
  void updateProject(Project project, {String? name, int? targetRow}) {
    if (name != null) project.name = name;
    if (project.rowCounter.target != null) {
      project.rowCounter.target!.targetValue = targetRow;
      _db.saveCounter(project.rowCounter.target!);
    }
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
