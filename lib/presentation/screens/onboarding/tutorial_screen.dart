import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/app_routes.dart';
import '../../providers/project_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../counter/widgets/counter_display.dart';
import '../counter/widgets/progress_header.dart';
import '../counter/widgets/project_info_bar.dart';
import '../counter/widgets/secondary_counter.dart';
import 'widgets/tutorial_overlay.dart';
import 'widgets/tutorial_tooltip.dart';
import 'widgets/tutorial_celebration.dart';

/// 튜토리얼 화면
/// - 데모 프로젝트로 카운터 화면 표시
/// - 스포트라이트 + 말풍선으로 롱프레스 기능 안내
class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  // 튜토리얼 대상 위젯들의 GlobalKey
  final GlobalKey _progressHeaderKey = GlobalKey();
  final GlobalKey _projectInfoBarKey = GlobalKey();
  final GlobalKey _secondaryCounterKey = GlobalKey();
  final GlobalKey _timerButtonKey = GlobalKey();
  final GlobalKey _voiceButtonKey = GlobalKey();

  bool _isInitialized = false;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTutorial();
    });
  }

  Future<void> _skipEntireTutorial() async {
    await ref.read(tutorialProvider.notifier).skipTutorial();
    // 활성 프로젝트 해제 및 프로젝트 목록 새로고침
    await ref.read(activeProjectIdProvider.notifier).setActiveProject(null);
    ref.read(projectsProvider.notifier).refresh();
    if (mounted) {
      context.go(AppRoutes.newProject);
    }
  }

  Future<void> _completeTutorialAndNavigate() async {
    await ref.read(tutorialProvider.notifier).completeTutorial();
    // 활성 프로젝트 해제 및 프로젝트 목록 새로고침
    await ref.read(activeProjectIdProvider.notifier).setActiveProject(null);
    ref.read(projectsProvider.notifier).refresh();
    if (mounted) {
      context.go(AppRoutes.newProject);
    }
  }

  Future<void> _initTutorial() async {
    final tutorialNotifier = ref.read(tutorialProvider.notifier);
    tutorialNotifier.startTutorial();

    // 데모 프로젝트를 활성화
    final tutorialState = ref.read(tutorialProvider);
    if (tutorialState.demoProjectId != null) {
      // 프로젝트 목록 새로고침 (새 데모 프로젝트 포함)
      ref.read(projectsProvider.notifier).refresh();

      // 활성 프로젝트 ID 설정
      await ref.read(activeProjectIdProvider.notifier).setActiveProject(
        tutorialState.demoProjectId,
      );
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorialState = ref.watch(tutorialProvider);
    final project = ref.watch(activeProjectProvider);
    final counterState = ref.watch(activeProjectCounterProvider);

    // 튜토리얼 초기화 중
    if (!_isInitialized || project == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '튜토리얼 준비 중...',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 축하 화면
    if (_showCelebration) {
      return TutorialCelebration(
        onComplete: _completeTutorialAndNavigate,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 메인 콘텐츠 (카운터 화면 재현) - SafeArea 적용
          SafeArea(
            child: _buildDemoCounterScreen(project, counterState),
          ),

          // 튜토리얼 오버레이 (환영/완료 제외) - SafeArea 외부에서 전체 화면 좌표 사용
          if (tutorialState.isActive &&
              tutorialState.currentStep != TutorialStep.welcome &&
              tutorialState.currentStep != TutorialStep.completed)
            _buildTutorialOverlay(tutorialState),

          // 환영 화면 오버레이
          if (tutorialState.currentStep == TutorialStep.welcome)
            _buildWelcomeOverlay(),
        ],
      ),
    );
  }

  Widget _buildDemoCounterScreen(dynamic project, ProjectCounterState counterState) {
    return Column(
      children: [
        // ProgressHeader (Step 1 타겟)
        Container(
          key: _progressHeaderKey,
          child: ProgressHeader(
            projectName: project.name,
            currentRow: counterState.currentRow,
            targetRow: counterState.targetRow,
            progress: counterState.progress,
            onTap: null, // 튜토리얼에서는 비활성화
            onLongPress: (sourceRect) {
              final tutorialState = ref.read(tutorialProvider);
              if (tutorialState.currentStep == TutorialStep.progressHeader) {
                HapticFeedback.mediumImpact();
                ref.read(tutorialProvider.notifier).nextStep();
              }
            },
          ),
        ),

        // ProjectInfoBar (Step 2 타겟)
        Container(
          key: _projectInfoBarKey,
          child: ProjectInfoBar(
            startDate: counterState.startDate,
            completedDate: counterState.completedDate,
            totalWorkSeconds: counterState.totalWorkSeconds,
            isTimerRunning: false,
            timerStartedAt: null,
            onLongPress: () {
              final tutorialState = ref.read(tutorialProvider);
              if (tutorialState.currentStep == TutorialStep.projectInfoBar) {
                HapticFeedback.mediumImpact();
                ref.read(tutorialProvider.notifier).nextStep();
              }
            },
          ),
        ),

        // 메인 콘텐츠
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),

                // 메인 카운터 (비활성화 - 빈 함수 전달)
                CounterDisplay(
                  value: counterState.currentRow,
                  label: AppStrings.row,
                  onIncrement: () {},
                  onDecrement: () {},
                ),

                const SizedBox(height: 16),

                // 보조 카운터 (Step 3 타겟)
                if (counterState.secondaryCounters.isNotEmpty)
                  Container(
                    key: _secondaryCounterKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: SecondaryCounter(
                            id: counterState.secondaryCounters.first.id,
                            value: counterState.secondaryCounters.first.value,
                            label: counterState.secondaryCounters.first.label,
                            type: counterState.secondaryCounters.first.type,
                            targetValue: counterState.secondaryCounters.first.targetValue,
                            resetAt: counterState.secondaryCounters.first.resetAt,
                            isLinked: false,
                            onIncrement: () {},
                            onDecrement: () {},
                            onLongPress: (sourceRect) {
                              final tutorialState = ref.read(tutorialProvider);
                              if (tutorialState.currentStep == TutorialStep.secondaryCounter) {
                                HapticFeedback.mediumImpact();
                                ref.read(tutorialProvider.notifier).nextStep();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),

                const Spacer(),

                // 액션 버튼 (Step 4 타겟 - 타이머 버튼)
                _buildActionButtons(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Undo (비활성화)
        _buildDisabledActionButton(Icons.undo, isDark),
        const SizedBox(width: 8),
        // Memo (비활성화)
        _buildDisabledActionButton(Icons.sticky_note_2_outlined, isDark),
        const SizedBox(width: 8),
        // Timer (Step 4 타겟)
        Container(
          key: _timerButtonKey,
          child: GestureDetector(
            onLongPress: () {
              final tutorialState = ref.read(tutorialProvider);
              if (tutorialState.currentStep == TutorialStep.timerReset) {
                HapticFeedback.mediumImpact();
                ref.read(tutorialProvider.notifier).nextStep();
              }
            },
            child: _buildDisabledActionButton(Icons.timer_outlined, isDark),
          ),
        ),
        const SizedBox(width: 8),
        // Voice (Step 5 타겟)
        Container(
          key: _voiceButtonKey,
          child: GestureDetector(
            onTap: () {
              final tutorialState = ref.read(tutorialProvider);
              if (tutorialState.currentStep == TutorialStep.voiceCommands) {
                HapticFeedback.mediumImpact();
                setState(() => _showCelebration = true);
              }
            },
            child: _buildDisabledActionButton(Icons.mic_none, isDark),
          ),
        ),
        const SizedBox(width: 8),
        // Settings (비활성화)
        _buildDisabledActionButton(Icons.settings, isDark),
      ],
    );
  }

  Widget _buildDisabledActionButton(IconData icon, bool isDark) {
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Icon(icon, color: textColor.withValues(alpha: 0.5), size: 22),
    );
  }

  Widget _buildTutorialOverlay(TutorialState tutorialState) {
    // 현재 단계에 맞는 타겟 Rect 가져오기
    Rect? targetRect;
    GlobalKey? targetKey;

    switch (tutorialState.currentStep) {
      case TutorialStep.progressHeader:
        targetKey = _progressHeaderKey;
        break;
      case TutorialStep.projectInfoBar:
        targetKey = _projectInfoBarKey;
        break;
      case TutorialStep.secondaryCounter:
        targetKey = _secondaryCounterKey;
        break;
      case TutorialStep.timerReset:
        targetKey = _timerButtonKey;
        break;
      case TutorialStep.voiceCommands:
        targetKey = _voiceButtonKey;
        break;
      default:
        break;
    }

    if (targetKey != null) {
      targetRect = getRectFromKey(targetKey);
    }

    // 음성 단계는 탭이므로 롱프레스 힌트 표시하지 않음
    final isLongPressStep = tutorialState.currentStep != TutorialStep.voiceCommands;

    return AnimatedTutorialOverlay(
      targetRect: targetRect,
      child: Stack(
        children: [
          // 롱프레스 힌트 아이콘 (탭 단계 제외)
          if (targetRect != null && isLongPressStep)
            LongPressHint(targetRect: targetRect),

          // 튜토리얼 말풍선
          _buildTooltip(tutorialState, targetRect),
        ],
      ),
    );
  }

  Widget _buildTooltip(TutorialState tutorialState, Rect? targetRect) {
    String title;
    String description;
    IconData icon;

    switch (tutorialState.currentStep) {
      case TutorialStep.progressHeader:
        title = AppStrings.tutorialStep1Title;
        description = AppStrings.tutorialStep1Description;
        icon = Icons.edit_outlined;
        break;
      case TutorialStep.projectInfoBar:
        title = AppStrings.tutorialStep2Title;
        description = AppStrings.tutorialStep2Description;
        icon = Icons.calendar_today_outlined;
        break;
      case TutorialStep.secondaryCounter:
        title = AppStrings.tutorialStep3Title;
        description = AppStrings.tutorialStep3Description;
        icon = Icons.tune;
        break;
      case TutorialStep.timerReset:
        title = AppStrings.tutorialStep4Title;
        description = AppStrings.tutorialStep4Description;
        icon = Icons.timer_outlined;
        break;
      case TutorialStep.voiceCommands:
        title = AppStrings.tutorialStep5Title;
        description = AppStrings.tutorialStep5Description;
        icon = Icons.mic;
        break;
      default:
        title = '';
        description = '';
        icon = Icons.info_outline;
    }

    return TutorialTooltip(
      targetRect: targetRect,
      title: title,
      description: description,
      icon: icon,
      currentStep: tutorialState.displayStepNumber,
      totalSteps: TutorialState.totalSteps,
      primaryButtonText: '다음',
      secondaryButtonText: AppStrings.tutorialSkip,
      onPrimaryTap: () {
        // 버튼으로도 다음 단계 진행 가능
        ref.read(tutorialProvider.notifier).nextStep();
        if (ref.read(tutorialProvider).currentStep == TutorialStep.completed) {
          setState(() => _showCelebration = true);
        }
      },
      onSecondaryTap: () {
        // 튜토리얼 전체 건너뛰기
        _skipEntireTutorial();
      },
    );
  }

  Widget _buildWelcomeOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.touch_app,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // 제목
              Text(
                '롱프레스 기능 알아보기',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 설명
              Text(
                '한코한코에서는 길게 누르면\n다양한 편집 기능을 사용할 수 있어요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(tutorialProvider.notifier).nextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 건너뛰기
              TextButton(
                onPressed: _skipEntireTutorial,
                child: Text(
                  AppStrings.tutorialSkip,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
