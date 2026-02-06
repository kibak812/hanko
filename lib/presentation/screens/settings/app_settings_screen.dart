import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/app_routes.dart';
import '../../providers/app_providers.dart';
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
