<!-- Parent: ../AGENTS.md -->
# lib/router/

네비게이션 라우팅 (go_router)

## Purpose

앱의 모든 화면 라우팅 정의. 딥링크, 라우트 가드 처리.

## Key Files

- `app_routes.dart` - 라우트 경로 상수 (AppRoutes 클래스)
- `app_router.dart` - GoRouter Provider 및 라우트 정의

## Routes

| 경로 | 화면 | 설명 |
|------|------|------|
| `/` | CounterScreen | 메인 카운터 |
| `/onboarding` | OnboardingScreen | 온보딩 |
| `/projects` | ProjectListScreen | 프로젝트 목록 |
| `/projects/settings` | ProjectSettingsScreen | 프로젝트 편집 |
| `/projects/new` | ProjectSettingsScreen | 새 프로젝트 |
| `/settings` | AppSettingsScreen | 앱 설정 |

## For AI Agents

### 새 라우트 추가 시
1. `app_routes.dart`의 `AppRoutes` 클래스에 경로 상수 추가
2. `app_router.dart`의 `GoRouter.routes`에 GoRoute 추가
3. 해당 Screen import 추가

### Import 규칙
- 화면에서 라우트 상수 사용 시: `import 'app_routes.dart'`
- GoRouter Provider 사용 시: `import 'app_router.dart'`
- 순환 import 방지를 위해 분리됨

### 네비게이션 사용
```dart
// 이동
context.push(AppRoutes.settings);

// 데이터 전달
context.push(AppRoutes.projectSettings, extra: projectId);

// 뒤로가기
context.pop();
```
