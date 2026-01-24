import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'presentation/providers/app_providers.dart';
import 'router/app_router.dart';

/// 한코한코 메인 앱 위젯
class HankoHankoApp extends ConsumerStatefulWidget {
  const HankoHankoApp({super.key});

  @override
  ConsumerState<HankoHankoApp> createState() => _HankoHankoAppState();
}

class _HankoHankoAppState extends ConsumerState<HankoHankoApp> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 RevenueCat에서 프리미엄 상태 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPremiumStatus();
    });
  }

  Future<void> _syncPremiumStatus() async {
    await ref.read(premiumStatusProvider.notifier).syncWithRevenueCat();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(appSettingsProvider);

    // 테마 모드 결정
    ThemeMode themeMode;
    switch (settings.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
    );
  }
}
