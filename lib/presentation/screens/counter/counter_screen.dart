import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/local_storage.dart';
import '../../../router/app_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../providers/voice_provider.dart';
import '../../../data/models/counter.dart';
import '../../../data/models/project.dart';
import 'widgets/counter_display.dart';
import 'widgets/memo_card.dart';
import 'widgets/secondary_counter.dart';
import 'widgets/action_buttons.dart';
import 'widgets/progress_header.dart';
import 'widgets/add_counter_button.dart';
import 'widgets/inline_counter_editor.dart';
import '../settings/widgets/add_secondary_counter_sheet.dart';

/// 메인 카운터 화면
class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  bool? _hasVibrator;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
    _initVibration();
    _applyWakelock();
  }

  Future<void> _initVibration() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  void _applyWakelock() {
    final settings = ref.read(appSettingsProvider);
    if (settings.keepScreenOn) {
      WakelockPlus.enable();
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  /// 플랫폼별 햅틱 피드백 (내부용)
  Future<void> _hapticFeedback({
    int duration = 20,
    int amplitude = 60,
  }) async {
    if (Platform.isAndroid) {
      // 안드로이드: Vibration 패키지 사용
      // _hasVibrator 초기화 전이면 직접 체크
      final hasVibrator = _hasVibrator ?? await Vibration.hasVibrator();
      if (hasVibrator == true) {
        final hasAmplitude = await Vibration.hasAmplitudeControl();
        if (hasAmplitude == true) {
          await Vibration.vibrate(duration: duration, amplitude: amplitude);
        } else {
          await Vibration.vibrate(duration: duration);
        }
      }
    } else {
      // iOS: 기존 HapticFeedback 사용
      if (duration >= 40) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
  }

  /// 설정 확인 후 햅틱 피드백 실행
  void _triggerHaptic({int duration = 20, int amplitude = 60}) {
    if (ref.read(appSettingsProvider).hapticFeedback) {
      _hapticFeedback(duration: duration, amplitude: amplitude);
    }
  }

  /// 더블탭 패턴 햅틱 (리셋 알림용)
  void _triggerDoubleHaptic() {
    if (ref.read(appSettingsProvider).hapticFeedback) {
      _hapticFeedback(duration: 15, amplitude: 60);
      Future.delayed(const Duration(milliseconds: 100), () {
        _hapticFeedback(duration: 15, amplitude: 60);
      });
    }
  }

  void _onIncrement() {
    _triggerHaptic(duration: 25, amplitude: 80);
    _flashController.forward().then((_) => _flashController.reverse());
    ref.read(activeProjectCounterProvider.notifier).incrementRow();
  }

  void _onDecrement() {
    _triggerHaptic(duration: 15, amplitude: 50);
    ref.read(activeProjectCounterProvider.notifier).decrementRow();
  }

  void _onUndo() {
    _triggerHaptic(duration: 10, amplitude: 40);
    ref.read(activeProjectCounterProvider.notifier).undo();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(activeProjectProvider);
    final counterState = ref.watch(activeProjectCounterProvider);
    final voiceState = ref.watch(voiceStateProvider);

    // 설정 변경 감지 - 화면 유지 설정
    ref.listen<AppSettings>(appSettingsProvider, (previous, next) {
      if (previous?.keepScreenOn != next.keepScreenOn) {
        if (next.keepScreenOn) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      }
    });

    // 카운터 이벤트 감지
    ref.listen<ProjectCounterState>(activeProjectCounterProvider, (previous, next) {
      // 레거시: 코 카운터 목표 달성
      if (next.stitchGoalReached && !(previous?.stitchGoalReached ?? false)) {
        _showGoalCompletedDialog(next.stitchTarget!);
        ref.read(activeProjectCounterProvider.notifier).clearEventFlags();
      }
      // 레거시: 패턴 자동 리셋
      if (next.patternWasReset && !(previous?.patternWasReset ?? false)) {
        _showAutoResetToast(next.patternResetAt!);
        ref.read(activeProjectCounterProvider.notifier).clearEventFlags();
      }
      // 동적 보조 카운터: 목표 달성
      if (next.goalReachedCounterId != null &&
          next.goalReachedCounterId != previous?.goalReachedCounterId) {
        final counter = next.secondaryCounters.firstWhere(
          (c) => c.id == next.goalReachedCounterId,
          orElse: () => next.secondaryCounters.first,
        );
        _showSecondaryGoalCompletedDialog(counter.label, counter.targetValue!);
        ref.read(activeProjectCounterProvider.notifier).clearEventFlags();
      }
      // 동적 보조 카운터: 자동 리셋
      if (next.resetTriggeredCounterId != null &&
          next.resetTriggeredCounterId != previous?.resetTriggeredCounterId) {
        final counter = next.secondaryCounters.firstWhere(
          (c) => c.id == next.resetTriggeredCounterId,
          orElse: () => next.secondaryCounters.first,
        );
        _showSecondaryAutoResetToast(counter.label, counter.resetAt!);
        ref.read(activeProjectCounterProvider.notifier).clearEventFlags();
      }
    });

    // 프로젝트가 없으면 생성 유도
    if (project == null) {
      return _buildNoProjectScreen(context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (프로젝트명 + 진행률) - 탭 영역에서 제외
            ProgressHeader(
              projectName: project.name,
              currentRow: counterState.currentRow,
              targetRow: counterState.targetRow,
              progress: counterState.progress,
              onTap: () => context.push(AppRoutes.projects),
            ),

            // 메인 콘텐츠 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // 메모 카드 (있을 때만)
                    if (counterState.currentMemo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: MemoCard(memo: counterState.currentMemo!),
                      ),

                    // 스크롤 가능한 카운터 영역
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 메인 숫자 표시 (인라인 +/- 버튼 포함)
                            AnimatedBuilder(
                              animation: _flashAnimation,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      if (_flashAnimation.value > 0)
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3 * _flashAnimation.value),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                    ],
                                  ),
                                  child: child,
                                );
                              },
                              child: CounterDisplay(
                                value: counterState.currentRow,
                                label: AppStrings.row,
                                onIncrement: _onIncrement,
                                onDecrement: _onDecrement,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 동적 보조 카운터 (2x2 그리드) + 추가 버튼
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 8.0;

                                // 프리미엄 사용자 또는 보조 카운터 2개 미만이면 추가 가능
                                final isPremium = ref.watch(premiumStatusProvider);
                                final canAddMore = isPremium ||
                                    counterState.secondaryCounters.length < 2;

                                // 아이템 목록 (카운터 + 추가버튼)
                                final items = <Widget>[
                                  for (final counter in counterState.secondaryCounters)
                                    SecondaryCounter(
                                      id: counter.id,
                                      value: counter.value,
                                      label: counter.label,
                                      type: counter.type,
                                      targetValue: counter.type == SecondaryCounterType.goal
                                          ? counter.targetValue
                                          : null,
                                      resetAt: counter.type == SecondaryCounterType.repetition
                                          ? counter.resetAt
                                          : null,
                                      isLinked: counter.isLinked,
                                      onIncrement: () {
                                        _triggerHaptic(duration: 15, amplitude: 50);
                                        ref
                                            .read(activeProjectCounterProvider.notifier)
                                            .incrementSecondaryCounter(counter.id);
                                      },
                                      onDecrement: () {
                                        _triggerHaptic(duration: 15, amplitude: 50);
                                        ref
                                            .read(activeProjectCounterProvider.notifier)
                                            .decrementSecondaryCounter(counter.id);
                                      },
                                      onLongPress: (sourceRect) =>
                                          _showInlineCounterEditor(project, counter, sourceRect),
                                      onLinkToggle: () {
                                        _triggerHaptic(duration: 10, amplitude: 40);
                                        ref
                                            .read(activeProjectCounterProvider.notifier)
                                            .toggleSecondaryCounterLink(counter.id);
                                      },
                                    ),
                                  if (canAddMore)
                                    AddCounterButton(
                                      onTap: () => _showAddSecondaryCounterSheet(project),
                                    ),
                                ];

                                // 2열 그리드로 배치 (IntrinsicHeight로 높이 맞춤)
                                final rows = <Widget>[];
                                for (var i = 0; i < items.length; i += 2) {
                                  final hasSecond = i + 1 < items.length;
                                  rows.add(
                                    Padding(
                                      padding: EdgeInsets.only(top: i > 0 ? spacing : 0),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(child: items[i]),
                                            SizedBox(width: spacing),
                                            Expanded(
                                              child: hasSecond ? items[i + 1] : const SizedBox(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(children: rows);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 보조 액션 버튼
                    ActionButtons(
                      onUndo: counterState.canUndo ? _onUndo : null,
                      onMemo: () {
                        _triggerHaptic(duration: 10, amplitude: 40);
                        context.push(AppRoutes.memos, extra: project.id);
                      },
                      onVoice: () async {
                        _triggerHaptic(duration: 10, amplitude: 40);

                        // 토글: 이미 듣고 있으면 중지
                        final currentState = ref.read(voiceStateProvider);
                        if (currentState == VoiceState.listening) {
                          await ref
                              .read(voiceStateProvider.notifier)
                              .stopVoiceCommand();
                          return;
                        }

                        // 프리미엄이 아닌 경우 사용량 체크
                        final isPremium = ref.read(premiumStatusProvider);
                        if (!isPremium) {
                          final remaining = ref.read(voiceUsageProvider);
                          if (remaining <= 0) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${AppStrings.voiceLimitReached} (3/3 사용)'),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: AppStrings.watchAdForVoice,
                                    onPressed: () {
                                      // 광고 시청 로직
                                    },
                                  ),
                                ),
                              );
                            }
                            return;
                          }
                        }

                        await ref
                            .read(voiceStateProvider.notifier)
                            .startVoiceCommand();
                      },
                      isListening: voiceState == VoiceState.listening,
                      onMenuAction: (action) {
                        switch (action) {
                          case MoreMenuAction.edit:
                            context.push(AppRoutes.projectSettings, extra: project.id);
                          case MoreMenuAction.projects:
                            context.push(AppRoutes.projects);
                          case MoreMenuAction.settings:
                            context.push(AppRoutes.settings);
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProjectScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🧶',
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.welcomeTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.welcomeSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.newProject),
                    child: const Text(AppStrings.startFirstProject),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 코 카운터 목표 달성 다이얼로그
  void _showGoalCompletedDialog(int target) {
    _triggerHaptic(duration: 40, amplitude: 100);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: AppIcons.goalIcon(size: 48, color: AppColors.success),
        title: Text('$target코 완료!'),
        content: const Text('목표에 도달했어요. 계속하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(activeProjectCounterProvider.notifier).resetStitch();
            },
            child: const Text('리셋하고 계속'),
          ),
        ],
      ),
    );
  }

  /// 패턴 자동 리셋 토스트
  void _showAutoResetToast(int resetAt) {
    _triggerDoubleHaptic();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            AppIcons.patternIcon(size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text('패턴 $resetAt회 완료 → 리셋됨'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  /// 동적 보조 카운터 목표 달성 다이얼로그
  void _showSecondaryGoalCompletedDialog(String label, int target) {
    _triggerHaptic(duration: 40, amplitude: 100);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: AppIcons.goalIcon(size: 48, color: AppColors.success),
        title: Text('$label $target 완료!'),
        content: const Text('목표에 도달했어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 동적 보조 카운터 자동 리셋 토스트
  void _showSecondaryAutoResetToast(String label, int resetAt) {
    _triggerDoubleHaptic();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            AppIcons.patternIcon(size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text('$label $resetAt회 완료 → 리셋됨'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  /// 보조 카운터 추가 바텀시트
  void _showAddSecondaryCounterSheet(Project project) {
    final isPremium = ref.read(premiumStatusProvider);
    final counterCount = ref.read(activeProjectCounterProvider).secondaryCounters.length;
    final canAdd = isPremium || counterCount < 2;

    showAddSecondaryCounterSheet(
      context: context,
      canAdd: canAdd,
      onAdd: (label, type, value) {
        final notifier = ref.read(projectsProvider.notifier);
        if (type == SecondaryCounterType.goal) {
          notifier.addSecondaryGoalCounter(
            project,
            label: label,
            targetValue: value,
          );
        } else {
          notifier.addSecondaryRepetitionCounter(
            project,
            label: label,
            resetAt: value,
          );
        }
        // ToMany 변경 감지를 위해 강제 리빌드
        ref.invalidate(activeProjectCounterProvider);
      },
    );
  }

  /// 인라인 카운터 편집기 표시
  void _showInlineCounterEditor(
    Project project,
    SecondaryCounterState counter,
    Rect sourceRect,
  ) {
    _triggerHaptic(duration: 25, amplitude: 80);

    showInlineCounterEditor(
      context: context,
      label: counter.label,
      type: counter.type,
      currentValue: counter.value,
      targetValue: counter.targetValue,
      resetAt: counter.resetAt,
      sourceRect: sourceRect,
      onReset: () {
        ref.read(activeProjectCounterProvider.notifier).resetSecondaryCounter(counter.id);
      },
      onSave: (newLabel, newTarget, newType) {
        // 새 타입 또는 기존 타입 사용
        final effectiveType = newType ?? counter.type;
        ref.read(projectsProvider.notifier).updateSecondaryCounter(
          project,
          counter.id,
          label: newLabel,
          targetValue: effectiveType == SecondaryCounterType.goal ? newTarget : null,
          resetAt: effectiveType == SecondaryCounterType.repetition ? newTarget : null,
          type: newType,
        );
        // 강제 리빌드
        ref.invalidate(activeProjectCounterProvider);
      },
      onRemove: () {
        ref.read(projectsProvider.notifier).removeSecondaryCounter(project, counter.id);
        // ToMany 변경 감지를 위해 강제 리빌드
        ref.invalidate(activeProjectCounterProvider);
      },
    );
  }
}
