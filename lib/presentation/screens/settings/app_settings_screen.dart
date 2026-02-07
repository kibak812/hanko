import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/app_routes.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../../widgets/ad_banner_widget.dart';

/// 앱 설정 화면
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  String _appVersion = '';
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),

                // 피드백 섹션
                _buildSectionHeader(context, AppStrings.feedbackSection),
                _buildSwitchTile(
                  context,
                  icon: Icons.vibration,
                  title: AppStrings.hapticFeedback,
                  subtitle: AppStrings.hapticFeedbackDesc,
                  value: settings.hapticFeedback,
                  onChanged: (value) => settingsNotifier.setHapticFeedback(value),
                ),

                const SizedBox(height: 24),

                // 화면 섹션
                _buildSectionHeader(context, AppStrings.displaySection),
                _buildSwitchTile(
                  context,
                  icon: Icons.screen_lock_portrait,
                  title: AppStrings.keepScreenOn,
                  subtitle: AppStrings.keepScreenOnDesc,
                  value: settings.keepScreenOn,
                  onChanged: (value) => settingsNotifier.setKeepScreenOn(value),
                ),

                // 테마 선택
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            AppStrings.themeSection,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildThemeSelector(context, settings.themeMode, settingsNotifier),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 도움말 섹션
                _buildSectionHeader(context, AppStrings.helpSection),
                ListTile(
                  leading: Icon(
                    Icons.school_outlined,
                    color: context.textSecondary,
                  ),
                  title: const Text(AppStrings.tutorialRewatch),
                  subtitle: Text(
                    AppStrings.tutorialRewatchDesc,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.textSecondary,
                  ),
                  onTap: () async {
                    // 튜토리얼 리셋 후 화면 이동
                    await ref.read(tutorialProvider.notifier).resetTutorial();
                    if (context.mounted) {
                      context.go(AppRoutes.tutorial);
                    }
                  },
                ),

                const SizedBox(height: 24),

                // 데이터 관리 섹션
                _buildSectionHeader(context, AppStrings.dataManagementSection),
                ListTile(
                  leading: Icon(
                    Icons.backup_outlined,
                    color: context.textSecondary,
                  ),
                  title: const Text(AppStrings.backupData),
                  subtitle: Text(
                    AppStrings.backupDataDesc,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: _isBackingUp
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.chevron_right,
                          color: context.textSecondary,
                        ),
                  onTap: _isBackingUp ? null : _handleBackup,
                ),
                ListTile(
                  leading: Icon(
                    Icons.restore,
                    color: context.textSecondary,
                  ),
                  title: const Text(AppStrings.restoreData),
                  subtitle: Text(
                    AppStrings.restoreDataDesc,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: _isRestoring
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.chevron_right,
                          color: context.textSecondary,
                        ),
                  onTap: _isRestoring ? null : _handleRestore,
                ),

                const SizedBox(height: 24),

                // 앱 정보 섹션
                _buildSectionHeader(context, AppStrings.about),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: context.textSecondary,
                  ),
                  title: const Text(AppStrings.appName),
                  subtitle: Text(_appVersion.isEmpty ? AppStrings.versionLoading : '버전 $_appVersion'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
          // 배너 광고 (하단)
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Future<void> _handleBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final file = await backupService.createBackupFile();
      await Share.shareXFiles([XFile(file.path)], subject: 'Hanko Backup');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.backupSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorOccurred}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _handleRestore() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.backupFileTooLarge)),
        );
      }
      return;
    }

    final jsonString = await file.readAsString();
    final backupService = ref.read(backupServiceProvider);
    final meta = backupService.validateBackup(jsonString);
    if (meta == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.invalidBackupFile)),
        );
      }
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.restoreConfirmTitle),
        content: Text(
          '${AppStrings.restoreConfirmBody}\n\n${AppStrings.restoreConfirmDetail(meta.projectCount, meta.createdAt)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isRestoring = true);
    try {
      backupService.restoreFromJson(jsonString);
      ref.invalidate(projectsProvider);
      ref.invalidate(activeProjectIdProvider);
      ref.invalidate(activeProjectCounterProvider);
      ref.invalidate(appSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.restoreSuccess)),
        );
        context.go(AppRoutes.projects);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorOccurred}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: context.textSecondary,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: context.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    String currentTheme,
    AppSettingsNotifier notifier,
  ) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(
          value: 'light',
          label: Text(AppStrings.themeLight),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment<String>(
          value: 'dark',
          label: Text(AppStrings.themeDark),
          icon: Icon(Icons.dark_mode),
        ),
        ButtonSegment<String>(
          value: 'system',
          label: Text(AppStrings.themeSystem),
          icon: Icon(Icons.settings_suggest),
        ),
      ],
      selected: {currentTheme},
      onSelectionChanged: (Set<String> selection) {
        notifier.setThemeMode(selection.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
