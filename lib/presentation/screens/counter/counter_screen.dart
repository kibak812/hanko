import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/app_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../providers/voice_provider.dart';
import 'widgets/counter_display.dart';
import 'widgets/memo_card.dart';
import 'widgets/secondary_counter.dart';
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
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _onIncrement() {
    final settings = ref.read(appSettingsProvider);

    // 햅틱 피드백
    if (settings.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    // 플래시 애니메이션
    _flashController.forward().then((_) => _flashController.reverse());

    // 카운터 증가
    ref.read(activeProjectCounterProvider.notifier).incrementRow();

    // 마일스톤 체크 (10단 단위)
    final newState = ref.read(activeProjectCounterProvider);
    if (newState.currentRow > 0 && newState.currentRow % 10 == 0) {
      _showMilestoneSnackBar(newState.currentRow);
    }
  }

  void _onDecrement() {
    final settings = ref.read(appSettingsProvider);
    if (settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    ref.read(activeProjectCounterProvider.notifier).decrementRow();
  }

  void _onUndo() {
    final settings = ref.read(appSettingsProvider);
    if (settings.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    ref.read(activeProjectCounterProvider.notifier).undo();
  }

  void _showMilestoneSnackBar(int row) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 $row${AppStrings.milestoneReached} ${AppStrings.greatJob}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(activeProjectProvider);
    final counterState = ref.watch(activeProjectCounterProvider);
    final voiceState = ref.watch(voiceStateProvider);

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
                          child: MemoCard(
                            memo: counterState.currentMemo!,
                            onDismiss: () {
                              // 메모 알림 처리
                            },
                          ),
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
                              onIncrement: () {
                                final settings = ref.read(appSettingsProvider);
                                if (settings.hapticFeedback) {
                                  HapticFeedback.lightImpact();
                                }
                                ref
                                    .read(activeProjectCounterProvider.notifier)
                                    .incrementStitch();
                              },
                              onReset: () {
                                ref
                                    .read(activeProjectCounterProvider.notifier)
                                    .resetStitch();
                              },
                            ),
                          if (project.stitchCounter.target != null &&
                              project.patternCounter.target != null)
                            const SizedBox(width: 24),
                          if (project.patternCounter.target != null)
                            SecondaryCounter(
                              value: counterState.currentPattern,
                              label: AppStrings.pattern,
                              onIncrement: () {
                                final settings = ref.read(appSettingsProvider);
                                if (settings.hapticFeedback) {
                                  HapticFeedback.lightImpact();
                                }
                                ref
                                    .read(activeProjectCounterProvider.notifier)
                                    .incrementPattern();
                              },
                              onReset: () {
                                ref
                                    .read(activeProjectCounterProvider.notifier)
                                    .resetPattern();
                              },
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
                            HapticFeedback.selectionClick();
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
                leading: const Icon(Icons.note_add),
                title: const Text(AppStrings.addMemo),
                onTap: () {
                  Navigator.pop(context);
                  _showAddMemoDialog(context);
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

  void _showAddMemoDialog(BuildContext context) {
    final rowController = TextEditingController();
    final contentController = TextEditingController();
    final counterState = ref.read(activeProjectCounterProvider);

    // 기본값으로 현재 단 + 1 설정
    rowController.text = (counterState.currentRow + 1).toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.addMemo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rowController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${AppStrings.row} 번호',
                hintText: '예: 50',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: AppStrings.memoHint,
                hintText: '예: 코 줄이기 2코',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final row = int.tryParse(rowController.text);
              final content = contentController.text.trim();

              if (row != null && content.isNotEmpty) {
                ref
                    .read(activeProjectCounterProvider.notifier)
                    .addMemo(row, content);
                Navigator.pop(context);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
