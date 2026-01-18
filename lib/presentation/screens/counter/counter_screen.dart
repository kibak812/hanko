import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/local_storage.dart';
import '../../../router/app_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../providers/voice_provider.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/counter.dart';
import 'widgets/counter_display.dart';
import 'widgets/memo_card.dart';
import 'widgets/secondary_counter.dart';
import 'widgets/counter_settings_sheet.dart';
import 'widgets/action_buttons.dart';
import 'widgets/progress_header.dart';

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

  /// 플랫폼별 햅틱 피드백
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

  void _onIncrement() {
    final settings = ref.read(appSettingsProvider);

    // 햅틱 피드백 (medium)
    if (settings.hapticFeedback) {
      _hapticFeedback(duration: 25, amplitude: 80);
    }

    // 플래시 애니메이션
    _flashController.forward().then((_) => _flashController.reverse());

    // 카운터 증가
    ref.read(activeProjectCounterProvider.notifier).incrementRow();
  }

  void _onDecrement() {
    final settings = ref.read(appSettingsProvider);
    if (settings.hapticFeedback) {
      _hapticFeedback(duration: 15, amplitude: 50);
    }
    ref.read(activeProjectCounterProvider.notifier).decrementRow();
  }

  void _onUndo() {
    final settings = ref.read(appSettingsProvider);
    if (settings.hapticFeedback) {
      _hapticFeedback(duration: 10, amplitude: 40);
    }
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

    // 코 카운터 목표 달성 감지
    ref.listen<ProjectCounterState>(activeProjectCounterProvider, (previous, next) {
      // 코 카운터 목표 달성
      if (next.stitchGoalReached && !(previous?.stitchGoalReached ?? false)) {
        _showGoalCompletedDialog(next.stitchTarget!);
        ref.read(activeProjectCounterProvider.notifier).clearEventFlags();
      }
      // 패턴 자동 리셋
      if (next.patternWasReset && !(previous?.patternWasReset ?? false)) {
        _showAutoResetToast(next.patternResetAt!);
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

            // 메인 콘텐츠 영역 - 탭하면 카운터 증가
            Expanded(
              child: GestureDetector(
                onTap: _onIncrement,
                behavior: HitTestBehavior.opaque,
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

                      const Spacer(),

                      // 메인 숫자 표시
                      AnimatedBuilder(
                        animation: _flashAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                if (_flashAnimation.value > 0)
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withOpacity(0.3 * _flashAnimation.value),
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
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 보조 카운터 (코, 패턴)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (project.stitchCounter.target != null)
                            SecondaryCounter(
                              value: counterState.currentStitch,
                              label: AppStrings.stitch,
                              targetValue: counterState.stitchTarget,
                              onIncrement: () {
                                final settings = ref.read(appSettingsProvider);
                                if (settings.hapticFeedback) {
                                  _hapticFeedback(duration: 15, amplitude: 50);
                                }
                                ref
                                    .read(activeProjectCounterProvider.notifier)
                                    .incrementStitch();
                              },
                              onLongPress: () => _showStitchSettings(project),
                            ),
                          if (project.stitchCounter.target != null &&
                              project.patternCounter.target != null)
                            const SizedBox(width: 16),
                          if (project.patternCounter.target != null)
                            SecondaryCounter(
                              value: counterState.currentPattern,
                              label: AppStrings.pattern,
                              resetAt: counterState.patternResetAt,
                              onIncrement: () {
                                final settings = ref.read(appSettingsProvider);
                                if (settings.hapticFeedback) {
                                  _hapticFeedback(duration: 15, amplitude: 50);
                                }
                                ref
                                    .read(activeProjectCounterProvider.notifier)
                                    .incrementPattern();
                              },
                              onLongPress: () => _showPatternSettings(project),
                            ),
                        ],
                      ),

                      const Spacer(),

                      // 보조 액션 버튼
                      ActionButtons(
                        onDecrement: _onDecrement,
                        onUndo: counterState.canUndo ? _onUndo : null,
                        onVoice: () async {
                          final settings = ref.read(appSettingsProvider);
                          if (settings.hapticFeedback) {
                            _hapticFeedback(duration: 10, amplitude: 40);
                          }

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
                        onMore: () {
                          _showMoreOptions(context);
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
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

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text(AppStrings.myProjects),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.projects);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text(AppStrings.edit),
                onTap: () {
                  Navigator.pop(context);
                  final project = ref.read(activeProjectProvider);
                  if (project != null) {
                    context.push(AppRoutes.projectSettings, extra: project.id);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text(AppStrings.memo),
                onTap: () {
                  Navigator.pop(context);
                  final project = ref.read(activeProjectProvider);
                  if (project != null) {
                    context.push(AppRoutes.memos, extra: project.id);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text(AppStrings.settings),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.settings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 코 카운터 목표 달성 다이얼로그
  void _showGoalCompletedDialog(int target) {
    final settings = ref.read(appSettingsProvider);
    if (settings.hapticFeedback) {
      _hapticFeedback(duration: 40, amplitude: 100);
    }

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
    final settings = ref.read(appSettingsProvider);
    if (settings.hapticFeedback) {
      // 더블탭 패턴 햅틱
      _hapticFeedback(duration: 15, amplitude: 60);
      Future.delayed(const Duration(milliseconds: 100), () {
        _hapticFeedback(duration: 15, amplitude: 60);
      });
    }

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

  /// 코 카운터 설정 바텀시트
  void _showStitchSettings(dynamic project) {
    final counterState = ref.read(activeProjectCounterProvider);

    showCounterSettingsSheet(
      context: context,
      type: CounterType.stitch,
      currentValue: counterState.currentStitch,
      targetValue: counterState.stitchTarget,
      onReset: () {
        ref.read(activeProjectCounterProvider.notifier).resetStitch();
      },
      onTargetChanged: (value) {
        ref.read(projectsProvider.notifier).updateStitchCounter(
          project,
          targetValue: value,
        );
      },
      onRemove: () {
        ref.read(projectsProvider.notifier).removeStitchCounter(project);
      },
    );
  }

  /// 패턴 카운터 설정 바텀시트
  void _showPatternSettings(dynamic project) {
    final counterState = ref.read(activeProjectCounterProvider);

    showCounterSettingsSheet(
      context: context,
      type: CounterType.pattern,
      currentValue: counterState.currentPattern,
      resetAt: counterState.patternResetAt,
      onReset: () {
        ref.read(activeProjectCounterProvider.notifier).resetPattern();
      },
      onTargetChanged: (value) {
        ref.read(projectsProvider.notifier).updatePatternCounter(
          project,
          resetAt: value,
        );
      },
      onRemove: () {
        ref.read(projectsProvider.notifier).removePatternCounter(project);
      },
    );
  }
}
