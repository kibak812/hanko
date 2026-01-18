import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import '../models/models.dart';

/// ObjectBox 데이터베이스 관리 클래스
class ObjectBoxDatabase {
  late final Store store;
  late final Box<Project> projectBox;
  late final Box<Counter> counterBox;
  late final Box<RowMemo> memoBox;

  ObjectBoxDatabase._create(this.store) {
    projectBox = Box<Project>(store);
    counterBox = Box<Counter>(store);
    memoBox = Box<RowMemo>(store);
  }

  /// 데이터베이스 초기화
  static Future<ObjectBoxDatabase> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${docsDir.path}/objectbox');
    return ObjectBoxDatabase._create(store);
  }

  /// 데이터베이스 닫기
  void close() {
    store.close();
  }

  // ============ 프로젝트 CRUD ============

  /// 모든 프로젝트 조회
  List<Project> getAllProjects() {
    return projectBox.getAll();
  }

  /// 프로젝트 ID로 조회
  Project? getProject(int id) {
    return projectBox.get(id);
  }

  /// 프로젝트 저장 (생성 또는 업데이트)
  int saveProject(Project project) {
    // 관련 카운터들도 함께 저장
    if (project.rowCounter.target != null) {
      counterBox.put(project.rowCounter.target!);
    }
    if (project.stitchCounter.target != null) {
      counterBox.put(project.stitchCounter.target!);
    }
    if (project.patternCounter.target != null) {
      counterBox.put(project.patternCounter.target!);
    }

    // 메모들 저장
    for (final memo in project.memos) {
      memoBox.put(memo);
    }

    return projectBox.put(project);
  }

  /// 프로젝트 삭제
  bool deleteProject(int id) {
    final project = projectBox.get(id);
    if (project == null) return false;

    // 관련 카운터 삭제
    if (project.rowCounter.target != null) {
      counterBox.remove(project.rowCounter.target!.id);
    }
    if (project.stitchCounter.target != null) {
      counterBox.remove(project.stitchCounter.target!.id);
    }
    if (project.patternCounter.target != null) {
      counterBox.remove(project.patternCounter.target!.id);
    }

    // 관련 메모 삭제
    for (final memo in project.memos) {
      memoBox.remove(memo.id);
    }

    return projectBox.remove(id);
  }

  /// 진행 중인 프로젝트 조회
  List<Project> getInProgressProjects() {
    final query = projectBox
        .query(Project_.statusIndex.equals(ProjectStatus.inProgress.index))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// 완료된 프로젝트 조회
  List<Project> getCompletedProjects() {
    final query = projectBox
        .query(Project_.statusIndex.equals(ProjectStatus.completed.index))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  // ============ 메모 CRUD ============

  /// 메모 저장
  int saveMemo(RowMemo memo) {
    return memoBox.put(memo);
  }

  /// 메모 삭제
  bool deleteMemo(int id) {
    return memoBox.remove(id);
  }

  // ============ 카운터 업데이트 ============

  /// 카운터 저장
  int saveCounter(Counter counter) {
    return counterBox.put(counter);
  }
}
