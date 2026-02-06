import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/app_routes.dart';
import '../../providers/app_providers.dart';

/// 온보딩 화면
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              // 앱 아이콘/로고
              Icon(
                Icons.texture,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              // 환영 메시지
              Text(
                AppStrings.welcomeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
              const Spacer(),
              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 온보딩 완료 처리
                    final localStorage = ref.read(localStorageProvider);
                    await localStorage.setOnboardingCompleted(true);

                    // 메인 화면으로 이동
                    if (context.mounted) {
                      context.go(AppRoutes.newProject);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    AppStrings.startFirstProject,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 튜토리얼 버튼
              TextButton(
                onPressed: () async {
                  // 온보딩 완료 처리
                  final localStorage = ref.read(localStorageProvider);
                  await localStorage.setOnboardingCompleted(true);

                  // 튜토리얼 화면으로 이동
                  if (context.mounted) {
                    context.go(AppRoutes.tutorial);
                  }
                },
                child: Text(
                  '${AppStrings.tutorialTitle} (${AppStrings.tutorialSubtitle})',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
