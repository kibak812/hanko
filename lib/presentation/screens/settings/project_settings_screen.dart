import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/counter.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../widgets/expandable_counter_option.dart';
import 'widgets/add_secondary_counter_sheet.dart';

/// 프로젝트 생성/편집 화면
class ProjectSettingsScreen extends ConsumerStatefulWidget {
  final int? projectId;

  const ProjectSettingsScreen({
    super.key,
    this.projectId,
  });

  @override
  ConsumerState<ProjectSettingsScreen> createState() =>
      _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends ConsumerState<ProjectSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _targetRowController;

  // 보조 카운터 설정 (레거시 - 새 프로젝트 생성용)
  bool _includeStitchCounter = false;
  bool _includePatternCounter = false;
  int? _stitchTarget;
  int? _patternResetAt;

  // 편집 모드에서 기존 카운터 존재 여부
  bool _hadStitchCounter = false;
  bool _hadPatternCounter = false;

  bool get isEditing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetRowController = TextEditingController();

    // 편집 모드면 기존 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEditing) {
        final project =
            ref.read(projectRepositoryProvider).getProject(widget.projectId!);
        if (project != null) {
          _nameController.text = project.name;
          _targetRowController.text = project.targetRow?.toString() ?? '';

          final stitchCounter = project.stitchCounter.target;
          final patternCounter = project.patternCounter.target;

          setState(() {
            _includeStitchCounter = stitchCounter != null;
            _includePatternCounter = patternCounter != null;
            _stitchTarget = stitchCounter?.targetValue;
            _patternResetAt = patternCounter?.resetAt;
            _hadStitchCounter = stitchCounter != null;
            _hadPatternCounter = patternCounter != null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetRowController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로젝트 이름을 입력해주세요')),
      );
      return;
    }

    final targetRow = int.tryParse(_targetRowController.text);

    if (isEditing) {
      // 기존 프로젝트 편집
      final project =
          ref.read(projectRepositoryProvider).getProject(widget.projectId!);
      if (project != null) {
        final notifier = ref.read(projectsProvider.notifier);

        // 이름 변경
        notifier.renameProject(project, name);

        // 코 카운터 추가/제거/업데이트 (레거시)
        if (_includeStitchCounter && !_hadStitchCounter) {
          notifier.addStitchCounter(project, targetValue: _stitchTarget);
        } else if (!_includeStitchCounter && _hadStitchCounter) {
          notifier.removeStitchCounter(project);
        } else if (_includeStitchCounter && _hadStitchCounter) {
          notifier.updateStitchCounter(project, targetValue: _stitchTarget);
        }

        // 패턴 카운터 추가/제거/업데이트 (레거시)
        if (_includePatternCounter && !_hadPatternCounter) {
          notifier.addPatternCounter(project, resetAt: _patternResetAt);
        } else if (!_includePatternCounter && _hadPatternCounter) {
          notifier.removePatternCounter(project);
        } else if (_includePatternCounter && _hadPatternCounter) {
          notifier.updatePatternCounter(project, resetAt: _patternResetAt);
        }
      }
      context.pop();
    } else {
      // 새 프로젝트 생성
      final newProject = ref.read(projectsProvider.notifier).createProject(
            name: name,
            targetRow: targetRow,
            includeStitchCounter: _includeStitchCounter,
            includePatternCounter: _includePatternCounter,
            stitchTarget: _stitchTarget,
            patternResetAt: _patternResetAt,
          );

      // 새 프로젝트를 활성화
      ref
          .read(activeProjectIdProvider.notifier)
          .setActiveProject(newProject.id);

      // 새 프로젝트 생성 후 메인 카운터 화면으로 이동
      context.go('/');
    }
  }

  void _addSecondaryCounter() {
    final project =
        ref.read(projectRepositoryProvider).getProject(widget.projectId!);
    if (project == null) return;

    final isPremium = ref.read(premiumStatusProvider);
    final canAdd = ref
        .read(projectsProvider.notifier)
        .canAddSecondaryCounter(project, isPremium: isPremium);

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
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final project = isEditing
        ? ref.read(projectRepositoryProvider).getProject(widget.projectId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.edit : AppStrings.newProject),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(AppStrings.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로젝트 이름
            Text(
              AppStrings.projectName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: AppStrings.projectNameHint,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // 목표 단수
            Text(
              AppStrings.targetRow,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetRowController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: AppStrings.targetRowHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.targetRowTip,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.7)
                    : AppColors.textSecondary.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // 보조 카운터 섹션
            Text(
              '보조 카운터',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // 편집 모드: 동적 보조 카운터 목록
            if (isEditing && project != null) ...[
              // 기존 보조 카운터들 표시
              if (project.secondaryCounters.isNotEmpty) ...[
                ...project.secondaryCounters.map((counter) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SecondaryCounterListItem(
                      label: counter.label,
                      type: counter.secondaryType,
                      value: counter.value,
                      targetValue: counter.targetValue,
                      resetAt: counter.resetAt,
                      onRemove: () {
                        ref
                            .read(projectsProvider.notifier)
                            .removeSecondaryCounter(project, counter.id);
                        setState(() {});
                      },
                      isDark: isDark,
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],

              // 보조 카운터 추가 버튼
              OutlinedButton.icon(
                onPressed: _addSecondaryCounter,
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addSecondaryCounter),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ] else ...[
              // 새 프로젝트: 기존 방식 (코/패턴 카운터)
              ExpandableCounterOption(
                icon: AppIcons.stitchIcon(
                  size: 24,
                  color: _includeStitchCounter
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                ),
                title: '코 카운터',
                subtitle: '현재 단에서 코 수를 추적',
                enabled: _includeStitchCounter,
                onEnabledChanged: (value) {
                  setState(() {
                    _includeStitchCounter = value;
                    if (!value) {
                      _stitchTarget = null;
                    }
                  });
                },
                presets: const [10, 20, 30],
                selectedValue: _stitchTarget,
                onValueChanged: (value) {
                  setState(() => _stitchTarget = value);
                },
                valueLabel: '목표 코 수 (선택)',
                valueTip: '목표에 도달하면 알려드려요',
              ),

              const SizedBox(height: 12),

              ExpandableCounterOption(
                icon: AppIcons.patternIcon(
                  size: 24,
                  color: _includePatternCounter
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                ),
                title: '패턴 반복 카운터',
                subtitle: '반복 패턴 추적',
                enabled: _includePatternCounter,
                onEnabledChanged: (value) {
                  setState(() {
                    _includePatternCounter = value;
                    if (!value) {
                      _patternResetAt = null;
                    }
                  });
                },
                presets: const [4, 6, 8],
                selectedValue: _patternResetAt,
                onValueChanged: (value) {
                  setState(() => _patternResetAt = value);
                },
                valueLabel: '자동 리셋 (몇 회마다?)',
                valueTip: '설정한 횟수에 도달하면 자동으로 0으로 리셋',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 보조 카운터 리스트 아이템
class _SecondaryCounterListItem extends StatelessWidget {
  final String label;
  final SecondaryCounterType type;
  final int value;
  final int? targetValue;
  final int? resetAt;
  final VoidCallback onRemove;
  final bool isDark;

  const _SecondaryCounterListItem({
    required this.label,
    required this.type,
    required this.value,
    this.targetValue,
    this.resetAt,
    required this.onRemove,
    required this.isDark,
  });

  bool get isGoal => type == SecondaryCounterType.goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGoal ? Icons.flag : Icons.refresh,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isGoal
                      ? '횟수: $value${targetValue != null ? ' / $targetValue' : ''}'
                      : '반복: $value${resetAt != null ? ' / $resetAt' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.error,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('카운터 제거'),
                  content: const Text('이 카운터를 제거할까요?\n현재 값은 사라집니다.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        onRemove();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('제거'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
