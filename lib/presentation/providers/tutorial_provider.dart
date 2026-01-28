import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/models/project.dart';
import '../../data/repositories/project_repository.dart';
import 'app_providers.dart';

/// 튜토리얼 단계 정의
enum TutorialStep {
  /// 환영 화면
  welcome,

  /// Step 1: 프로젝트명/목표 편집 (ProgressHeader 롱프레스)
  progressHeader,

  /// Step 2: 시작일/완료일 편집 (ProjectInfoBar 롱프레스)
  projectInfoBar,

  /// Step 3: 보조 카운터 편집 (SecondaryCounter 롱프레스)
  secondaryCounter,

  /// Step 4: 작업 시간 리셋 (Timer 버튼 롱프레스)
  timerReset,

  /// Step 5: 음성 명령어 안내 (Voice 버튼 탭)
  voiceCommands,

  /// 튜토리얼 완료
  completed,
}

/// 튜토리얼 상태
class TutorialState {
  final TutorialStep currentStep;
  final bool isActive;
  final int? demoProjectId;
  final GlobalKey? targetKey;

  const TutorialState({
    this.currentStep = TutorialStep.welcome,
    this.isActive = false,
    this.demoProjectId,
    this.targetKey,
  });

  TutorialState copyWith({
    TutorialStep? currentStep,
    bool? isActive,
    int? demoProjectId,
    GlobalKey? targetKey,
    bool clearDemoProjectId = false,
    bool clearTargetKey = false,
  }) {
    return TutorialState(
      currentStep: currentStep ?? this.currentStep,
      isActive: isActive ?? this.isActive,
      demoProjectId: clearDemoProjectId ? null : (demoProjectId ?? this.demoProjectId),
      targetKey: clearTargetKey ? null : (targetKey ?? this.targetKey),
    );
  }

  /// 현재 단계 인덱스 (0~5)
  int get stepIndex => currentStep.index;

  /// 총 단계 수 (welcome, completed 제외)
  static const int totalSteps = 5;

  /// 현재 표시 단계 번호 (1~5, welcome/completed는 0)
  int get displayStepNumber {
    switch (currentStep) {
      case TutorialStep.welcome:
      case TutorialStep.completed:
        return 0;
      case TutorialStep.progressHeader:
        return 1;
      case TutorialStep.projectInfoBar:
        return 2;
      case TutorialStep.secondaryCounter:
        return 3;
      case TutorialStep.timerReset:
        return 4;
      case TutorialStep.voiceCommands:
        return 5;
    }
  }
}

/// 튜토리얼 상태 관리 Notifier
class TutorialNotifier extends StateNotifier<TutorialState> {
  final LocalStorage _localStorage;
  final ProjectRepository _projectRepository;

  TutorialNotifier(this._localStorage, this._projectRepository)
      : super(const TutorialState());

  /// 튜토리얼 시작
  void startTutorial() {
    // 데모 프로젝트 생성
    final demoProject = _createDemoProject();

    state = state.copyWith(
      currentStep: TutorialStep.welcome,
      isActive: true,
      demoProjectId: demoProject.id,
    );
  }

  /// 튜토리얼 다음 단계로 진행
  void nextStep() {
    final nextIndex = state.currentStep.index + 1;
    if (nextIndex < TutorialStep.values.length) {
      state = state.copyWith(
        currentStep: TutorialStep.values[nextIndex],
        clearTargetKey: true,
      );
    }
  }

  /// 특정 단계로 이동
  void goToStep(TutorialStep step) {
    state = state.copyWith(
      currentStep: step,
      clearTargetKey: true,
    );
  }

  /// 현재 단계 스킵
  void skipStep() {
    nextStep();
  }

  /// 튜토리얼 완료
  Future<void> completeTutorial() async {
    await _localStorage.setTutorialCompleted(true);
    _cleanupDemoProject();

    state = state.copyWith(
      currentStep: TutorialStep.completed,
      isActive: false,
      clearDemoProjectId: true,
    );
  }

  /// 튜토리얼 스킵 (즉시 종료)
  Future<void> skipTutorial() async {
    await _localStorage.setTutorialCompleted(true);
    _cleanupDemoProject();

    state = state.copyWith(
      currentStep: TutorialStep.welcome,
      isActive: false,
      clearDemoProjectId: true,
    );
  }

  /// 튜토리얼 리셋 (다시 보기용)
  Future<void> resetTutorial() async {
    await _localStorage.setTutorialCompleted(false);
    state = const TutorialState();
  }

  /// 타겟 키 설정 (스포트라이트용)
  void setTargetKey(GlobalKey key) {
    state = state.copyWith(targetKey: key);
  }

  /// 데모 프로젝트 생성
  Project _createDemoProject() {
    // 프로젝트 생성
    final project = _projectRepository.createProject(
      name: '연습 프로젝트',
      targetRow: 100,
    );

    // currentRow 설정 (25단)
    if (project.rowCounter.target != null) {
      project.rowCounter.target!.value = 25;
    }

    // 시작일 설정 (3일 전)
    project.startDate = DateTime.now().subtract(const Duration(days: 3));

    // 작업 시간 설정 (1시간)
    project.totalWorkSeconds = 3600;

    // 저장
    _projectRepository.saveProject(project);

    // 보조 카운터 추가 (목표형: 패턴 3/10)
    final counter = _projectRepository.addSecondaryGoalCounter(
      project,
      label: '패턴',
      targetValue: 10,
    );

    // 보조 카운터 값 설정 (3)
    counter.value = 3;
    _projectRepository.saveProject(project);

    return project;
  }

  /// 데모 프로젝트 삭제
  void _cleanupDemoProject() {
    final projectId = state.demoProjectId;
    if (projectId != null) {
      _projectRepository.deleteProject(projectId);
    }
  }
}

/// 튜토리얼 Provider
final tutorialProvider =
    StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  return TutorialNotifier(localStorage, projectRepository);
});

/// 튜토리얼 완료 여부 Provider
final tutorialCompletedProvider = Provider<bool>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return localStorage.isTutorialCompleted();
});
