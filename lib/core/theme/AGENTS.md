<!-- Parent: ../AGENTS.md -->
# lib/core/theme/

Material 테마 설정

## Key Files

- `app_theme.dart` - 라이트/다크 테마 정의

## Theme Structure

```dart
AppTheme.lightTheme  // ThemeData
AppTheme.darkTheme   // ThemeData
```

## Customized Components

- `ElevatedButton` - Coral 그라데이션 배경
- `TextField` - 둥근 모서리
- `Card` - 부드러운 그림자
- `AppBar` - 투명 배경

## For AI Agents

- 새 위젯 스타일 추가 시 `copyWith` 사용
- 색상은 `AppColors` 참조
