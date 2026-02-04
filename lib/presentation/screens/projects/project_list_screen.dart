import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/project.dart';
import '../../../router/app_routes.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../widgets/ad_banner_widget.dart';
import 'widgets/project_card.dart';

/// 프로젝트 목록 화면
class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(projectsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final activeProjectId = ref.watch(activeProjectIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myProjects),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: projects.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final isActive = project.id == activeProjectId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProjectCard(
                          project: project,
                          isActive: isActive,
                          onTap: () async {
                            ref
                                .read(activeProjectIdProvider.notifier)
                                .setActiveProject(project.id);
                            // 프로젝트 선택 시 전면 광고 표시
                            await ref.read(interstitialAdControllerProvider).tryShowAd();
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                          onEdit: () {
                            context.push(AppRoutes.projectSettings, extra: project.id);
                          },
                          onDelete: () {
                            _showDeleteDialog(context, ref, project);
                          },
                        ),
                      );
                    },
                  ),
          ),
          // 배너 광고 (하단)
          const AdBannerWidget(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.newProject),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.newProject),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧶', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              AppStrings.noProjects,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: Text('\'${project.name}\' 프로젝트를 삭제할까요?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              ref.read(projectsProvider.notifier).deleteProject(project.id);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

}
