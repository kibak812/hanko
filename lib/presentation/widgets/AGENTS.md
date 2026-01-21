<!-- Parent: ../AGENTS.md -->
# lib/presentation/widgets/

공통 재사용 위젯

## Key Files

| 파일 | 역할 |
|------|------|
| `ad_banner_widget.dart` | 하단 배너 광고 위젯 (프리미엄 사용자 제외) |
| `expandable_counter_option.dart` | 확장형 토글 카드 (프로젝트 설정용) |
| `large_area_button.dart` | 카운터 하단 +/- 버튼 (넓은 터치 영역) |
| `dialogs.dart` | 공통 다이얼로그 유틸리티 함수 |
| `widget_extensions.dart` | BuildContext extension (getWidgetRect 등) |

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

## large_area_button.dart

넓은 터치 영역을 가진 아이콘 버튼. 메인/보조 카운터 하단의 +/- 버튼에 사용.

```dart
// 기본 (보조 카운터용)
LargeAreaButton(
  icon: Icons.add,
  onPressed: () {},
  color: textSecondary,
  borderRadius: BorderRadius.circular(15),
)

// 큰 버튼 (메인 카운터용)
LargeAreaButton.large(
  icon: Icons.remove,
  onPressed: () {},
  color: textSecondary,
  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
)
```

## dialogs.dart

공통 다이얼로그 유틸리티 함수.

```dart
// 카운터 제거 확인 다이얼로그
final confirmed = await showRemoveCounterDialog(context);
if (confirmed) {
  // 제거 로직
}
```

## Subdirectories

- `ads/` - 광고 관련 위젯
- `common/` - 범용 공통 위젯

## ad_banner_widget.dart

하단 배너 광고 위젯. 프리미엄 사용자는 자동으로 숨김 처리.

```dart
// 기본 (하단 패딩 8px)
const AdBannerWidget()

// 커스텀 패딩
const AdBannerWidget(bottomPadding: 0)
```

## widget_extensions.dart

BuildContext extension 모음. 위젯에서 공통으로 사용되는 유틸리티 메서드.

```dart
// 위젯의 Rect 가져오기 (롱프레스 시 소스 위치 전달용)
final rect = context.getWidgetRect();
```

## For AI Agents

- 여러 화면에서 재사용되는 위젯만 이 폴더에 추가
- 특정 화면 전용 위젯은 `screens/{feature}/widgets/`에 배치
