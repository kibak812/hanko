<!-- Parent: ../AGENTS.md -->
# lib/presentation/providers/

Riverpod Provider 정의

## Key Files

| 파일 | 역할 |
|------|------|
| `app_providers.dart` | 앱 설정, 프리미엄, 음성 사용량 Provider |
| `project_provider.dart` | 프로젝트 및 카운터 상태 Provider |
| `voice_provider.dart` | 음성 인식 상태 Provider |
| `tutorial_provider.dart` | 튜토리얼 상태 관리 (TutorialStep, TutorialState) |
| `providers.dart` | 모든 Provider export |

## 주요 Providers

```dart
// 앱 설정
appSettingsProvider          // AppSettings 상태
premiumStatusProvider        // 프리미엄 여부
voiceUsageProvider          // 음성 남은 횟수

// 프로젝트
projectListProvider         // 모든 프로젝트 목록
activeProjectProvider       // 현재 활성 프로젝트
activeProjectCounterProvider // 카운터 상태 (단/코/패턴)

// 음성
voiceStateProvider          // VoiceState (idle/listening/...)

// 백업
backupServiceProvider       // BackupService 인스턴스

// 튜토리얼
tutorialProvider            // TutorialState (currentStep, isActive, demoProjectId)
tutorialCompletedProvider   // 튜토리얼 완료 여부
```

## For AI Agents

### Provider 사용 패턴
```dart
// 상태 구독 (rebuild)
final settings = ref.watch(appSettingsProvider);

// 상태 읽기 (no rebuild)
final settings = ref.read(appSettingsProvider);

// 액션 실행
ref.read(appSettingsProvider.notifier).setHapticFeedback(true);
```
