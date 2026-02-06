<!-- Parent: ../AGENTS.md -->
# lib/core/utils/

공통 유틸리티 함수

## Key Files

| 파일 | 역할 |
|------|------|
| `formatters.dart` | 날짜/시간 포맷팅 유틸 (`formatDuration`, `formatDateFull`, `formatDateCompact`) |

## formatters.dart

여러 화면에서 중복되던 날짜/시간 포맷팅 로직을 통합.

```dart
// 초 -> "1시간 30분 15초" 형태
formatDuration(5415); // "1시간 30분 15초"

// DateTime -> "2026년 1월 19일"
formatDateFull(DateTime.now());

// DateTime -> "1/19"
formatDateCompact(DateTime.now());
```

## For AI Agents

- 순수 Dart 유틸만 배치 (Flutter 의존 없음)
- 비즈니스 로직 없이 포맷팅/변환만 담당
