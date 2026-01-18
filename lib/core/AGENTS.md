<!-- Parent: ../AGENTS.md -->
# lib/core/

앱 전역에서 사용되는 상수, 테마, 유틸리티

## Purpose

모든 레이어에서 공유되는 기초 코드. 비즈니스 로직 없음.

## Subdirectories

- `constants/` - 색상, 문자열, 음성 명령어 상수 (see constants/AGENTS.md)
- `theme/` - Material 테마 설정 (see theme/AGENTS.md)
- `utils/` - 유틸리티 함수 (see utils/AGENTS.md)

## For AI Agents

### 상수 추가 시
1. 색상 → `constants/app_colors.dart`
2. 문자열 → `constants/app_strings.dart`
3. 음성 명령어 → `constants/voice_commands.dart`

### 주의사항
- 이 디렉토리의 코드는 다른 레이어에 의존하면 안 됨
- 순수 Dart + Flutter 기본 패키지만 사용
