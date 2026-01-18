<!-- Parent: ../AGENTS.md -->
# lib/domain/

도메인 레이어 - 비즈니스 로직 서비스

## Purpose

앱의 핵심 비즈니스 로직. 음성 인식, 광고, 프리미엄 구독 관리.

## Subdirectories

- `services/` - 비즈니스 서비스 클래스 (see services/AGENTS.md)

## Key Services

| 서비스 | 역할 |
|--------|------|
| VoiceService | 음성 인식 (speech_to_text) + TTS (flutter_tts) |
| AdService | Google AdMob 광고 관리 |
| PremiumService | RevenueCat 구독 관리 |

## For AI Agents

### 서비스 작성 규칙
- 상태 없는 로직: 일반 클래스
- 상태 있는 로직: StateNotifier 또는 ChangeNotifier
- UI 의존성 없어야 함 (BuildContext 사용 금지)
