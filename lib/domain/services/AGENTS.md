<!-- Parent: ../AGENTS.md -->
# lib/domain/services/

비즈니스 로직 서비스

## Key Files

| 파일 | 서비스 | 역할 |
|------|--------|------|
| `voice_service.dart` | VoiceService | 음성 인식 + TTS |
| `ad_service.dart` | AdService | Google AdMob (`kReleaseMode`로 프로덕션/테스트 ID 자동 전환) |
| `premium_service.dart` | PremiumService | RevenueCat 구독 |
| `backup_service.dart` | BackupService | 데이터 백업 생성/검증/복원 (JSON 파일 기반) |

## VoiceService

```dart
final voice = VoiceService();

// 음성 인식
await voice.startListening(
  onCommand: (cmd) => ...,
  onError: (err) => ...,
);
await voice.stopListening();

// TTS 피드백
await voice.announceCount(10, '단');
await voice.announceStatus(row, stitch);
```

## For AI Agents

### 음성 명령어 추가
1. `voice_commands.dart`에 enum 추가
2. `voice_service.dart`의 `_parseCommand`에 패턴 추가
3. `voice_provider.dart`의 `_executeCommand`에 핸들러 추가
