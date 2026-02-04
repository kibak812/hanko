import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/counter.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/dialogs.dart';
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

/// 새 프로젝트용 임시 보조 카운터 데이터
class _PendingSecondaryCounter {
  final String label;
  final SecondaryCounterType type;
  final int? value;

  _PendingSecondaryCounter({
    required this.label,
    required this.type,
    this.value,
  });
}

class _ProjectSettingsScreenState extends ConsumerState<ProjectSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _targetRowController;

  // 새 프로젝트용 임시 보조 카운터 목록
  final List<_PendingSecondaryCounter> _pendingSecondaryCounters = [];

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

  Future<void> _save() async {
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
        notifier.updateProject(
          project.id,
          name: name,
          targetRow: targetRow,
        );
      }
      if (mounted) context.pop();
    } else {
      // 새 프로젝트 생성
      final newProject = ref.read(projectsProvider.notifier).createProject(
            name: name,
            targetRow: targetRow,
          );

      // 보조 카운터 추가
      final notifier = ref.read(projectsProvider.notifier);
      for (final counter in _pendingSecondaryCounters) {
        if (counter.type == SecondaryCounterType.goal) {
          notifier.addSecondaryGoalCounter(
            newProject,
            label: counter.label,
            targetValue: counter.value,
          );
        } else {
          notifier.addSecondaryRepetitionCounter(
            newProject,
            label: counter.label,
            resetAt: counter.value,
          );
        }
      }

      // 새 프로젝트를 활성화
      ref
          .read(activeProjectIdProvider.notifier)
          .setActiveProject(newProject.id);

      // 첫 프로젝트가 아닐 때만 전면 광고 표시 (온보딩 경험 개선)
      final projectCount = ref.read(projectsProvider).length;
      if (projectCount > 1) {
        await ref.read(interstitialAdControllerProvider).tryShowAd();
      }

      // 새 프로젝트 생성 후 메인 카운터 화면으로 이동
      if (mounted) {
        context.go('/');
      }
    }
  }

  void _addSecondaryCounter() {
    if (isEditing) {
      // 편집 모드: 기존 프로젝트에 직접 추가
      final project =
          ref.read(projectRepositoryProvider).getProject(widget.projectId!);
      if (project == null) return;

      showAddSecondaryCounterSheet(
        context: context,
        canAdd: true,
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
    } else {
      // 새 프로젝트 모드: 임시 목록에 추가
      showAddSecondaryCounterSheet(
        context: context,
        canAdd: true,
        onAdd: (label, type, value) {
          setState(() {
            _pendingSecondaryCounters.add(_PendingSecondaryCounter(
              label: label,
              type: type,
              value: value,
            ));
          });
        },
      );
    }
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                    : AppColors.textSecondary.withValues(alpha: 0.7),
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

            // 편집 모드: 기존 프로젝트의 보조 카운터 목록
            if (isEditing && project != null) ...[
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
            ] else ...[
              // 새 프로젝트: 임시 보조 카운터 목록
              if (_pendingSecondaryCounters.isNotEmpty) ...[
                ..._pendingSecondaryCounters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final counter = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SecondaryCounterListItem(
                      label: counter.label,
                      type: counter.type,
                      value: 0,
                      targetValue: counter.type == SecondaryCounterType.goal
                          ? counter.value
                          : null,
                      resetAt: counter.type == SecondaryCounterType.repetition
                          ? counter.value
                          : null,
                      onRemove: () {
                        setState(() {
                          _pendingSecondaryCounters.removeAt(index);
                        });
                      },
                      isDark: isDark,
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
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
          ],
        ),
      ),
          ),
          // 배너 광고 (하단)
          const AdBannerWidget(),
        ],
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
            onPressed: () async {
              final confirmed = await showRemoveCounterDialog(context);
              if (confirmed) {
                onRemove();
              }
            },
          ),
        ],
      ),
    );
  }
}
