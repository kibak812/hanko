<!-- Parent: ../AGENTS.md -->
# lib/presentation/widgets/

공통 재사용 위젯

## Key Files

| 파일 | 역할 |
|------|------|
| `expandable_counter_option.dart` | 확장형 토글 카드 (프로젝트 설정용) |

## expandable_counter_option.dart

보조 카운터 옵션 UI. 토글 시 확장되어 프리셋 버튼 표시.

```dart
ExpandableCounterOption(
  icon: AppIcons.stitchIcon(),
  title: '코 카운터',
  subtitle: '현재 단에서 코 수를 추적',
  enabled: true,
  onEnabledChanged: (value) {},
  presets: [10, 20, 30],
  selectedValue: 20,
  onValueChanged: (value) {},
)
```

## Subdirectories

- `ads/` - 광고 관련 위젯
- `common/` - 범용 공통 위젯

## For AI Agents

- 여러 화면에서 재사용되는 위젯만 이 폴더에 추가
- 특정 화면 전용 위젯은 `screens/{feature}/widgets/`에 배치
