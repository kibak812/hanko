<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/

앱 화면들

## Subdirectories

| 폴더 | 화면 | 설명 |
|------|------|------|
| `counter/` | CounterScreen | 메인 카운터 화면 |
| `projects/` | ProjectListScreen | 프로젝트 목록 |
| `settings/` | AppSettingsScreen, ProjectSettingsScreen | 설정 화면들 |
| `onboarding/` | OnboardingScreen | 첫 실행 온보딩 |

## Screen Structure

각 화면 폴더 구조:
```
{feature}/
├── {feature}_screen.dart     # 메인 화면
└── widgets/                  # 화면 전용 위젯
    ├── widget_a.dart
    └── widget_b.dart
```

## For AI Agents

### 새 화면 추가 시
1. `screens/{feature}/` 폴더 생성
2. `{feature}_screen.dart` 작성
3. `router/app_router.dart`에 라우트 추가
4. 필요시 `widgets/` 폴더에 전용 위젯 분리
