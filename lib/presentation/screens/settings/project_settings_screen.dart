import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';

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
  bool _includeStitchCounter = false;
  bool _includePatternCounter = false;

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
          setState(() {
            _includeStitchCounter = project.stitchCounter.target != null;
            _includePatternCounter = project.patternCounter.target != null;
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
        ref.read(projectsProvider.notifier).renameProject(project, name);
        // TODO: 목표 단수 수정 기능 추가
      }
    } else {
      // 새 프로젝트 생성
      final newProject = ref.read(projectsProvider.notifier).createProject(
            name: name,
            targetRow: targetRow,
            includeStitchCounter: _includeStitchCounter,
            includePatternCounter: _includePatternCounter,
          );

      // 새 프로젝트를 활성화
      ref
          .read(activeProjectIdProvider.notifier)
          .setActiveProject(newProject.id);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

            if (!isEditing) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // 보조 카운터 옵션
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

              // 코 카운터
              _buildToggleOption(
                icon: '🧵',
                title: '코 카운터 추가',
                subtitle: '현재 단에서 코 수를 추적',
                value: _includeStitchCounter,
                onChanged: (value) {
                  setState(() => _includeStitchCounter = value);
                },
              ),

              const SizedBox(height: 12),

              // 패턴 반복 카운터
              _buildToggleOption(
                icon: '🔄',
                title: '패턴 반복 카운터 추가',
                subtitle: '반복 패턴 추적 (예: 8코마다)',
                value: _includePatternCounter,
                onChanged: (value) {
                  setState(() => _includePatternCounter = value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
