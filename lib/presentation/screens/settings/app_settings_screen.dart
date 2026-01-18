import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/app_providers.dart';

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
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // 피드백 섹션
          _buildSectionHeader(context, '피드백'),
          _buildSwitchTile(
            context,
            icon: Icons.vibration,
            title: AppStrings.hapticFeedback,
            subtitle: '탭할 때 진동 피드백',
            value: settings.hapticFeedback,
            onChanged: (value) => settingsNotifier.setHapticFeedback(value),
          ),
          _buildSwitchTile(
            context,
            icon: Icons.volume_up,
            title: AppStrings.voiceFeedback,
            subtitle: '음성 명령 후 소리로 알려줘요',
            value: settings.voiceFeedback,
            onChanged: (value) => settingsNotifier.setVoiceFeedback(value),
          ),

          const SizedBox(height: 24),

          // 화면 섹션
          _buildSectionHeader(context, '화면'),
          _buildSwitchTile(
            context,
            icon: Icons.screen_lock_portrait,
            title: AppStrings.keepScreenOn,
            subtitle: '뜨개질하는 동안 화면이 꺼지지 않아요',
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
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '테마',
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

          // 앱 정보 섹션
          _buildSectionHeader(context, AppStrings.about),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            title: const Text(AppStrings.appName),
            subtitle: Text(_appVersion.isEmpty ? '버전 정보 로딩 중...' : '버전 $_appVersion'),
          ),

          const SizedBox(height: 32),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
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
          label: Text('라이트'),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment<String>(
          value: 'dark',
          label: Text('다크'),
          icon: Icon(Icons.dark_mode),
        ),
        ButtonSegment<String>(
          value: 'system',
          label: Text('시스템'),
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
