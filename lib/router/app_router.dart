import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_routes.dart';
import '../presentation/providers/app_providers.dart';
import '../presentation/screens/counter/counter_screen.dart';
import '../presentation/screens/memo/memo_list_screen.dart';
import '../presentation/screens/projects/project_list_screen.dart';
import '../presentation/screens/settings/project_settings_screen.dart';
import '../presentation/screens/settings/app_settings_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/onboarding/tutorial_screen.dart';

/// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  final isOnboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation: isOnboardingCompleted ? AppRoutes.counter : AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.tutorial,
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: AppRoutes.counter,
        builder: (context, state) => const CounterScreen(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        builder: (context, state) => const ProjectListScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectSettings,
        builder: (context, state) {
          final projectId = state.extra as int?;
          return ProjectSettingsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.newProject,
        builder: (context, state) => const ProjectSettingsScreen(projectId: null),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.memos,
        builder: (context, state) {
          final projectId = state.extra as int;
          return MemoListScreen(projectId: projectId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.uri}'),
      ),
    ),
  );
});
