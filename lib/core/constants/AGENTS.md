<!-- Parent: ../AGENTS.md -->
# lib/core/constants/

앱 전역 상수 정의

## Key Files

| 파일 | 역할 |
|------|------|
| `app_colors.dart` | 색상 팔레트 (라이트/다크 모드) |
| `app_strings.dart` | UI 문자열 상수 (한국어) |
| `voice_commands.dart` | 음성 명령어 매핑 |

## app_colors.dart

```dart
// 주요 색상
AppColors.primary      // #FF6B6B (Wool Coral)
AppColors.secondary    // #E07A5F (Terracotta)
AppColors.background   // #FAF3E0 (Warm Cream)
AppColors.surface      // #FFFFFF (White)

// 다크모드
AppColors.primaryDark
AppColors.backgroundDark
```

## app_strings.dart

모든 사용자 표시 문자열. 다국어 지원 준비됨.

## For AI Agents

- 새 색상 추가 시 라이트/다크 모드 둘 다 정의
- 문자열 추가 시 `AppStrings` 클래스에 static const로 추가
