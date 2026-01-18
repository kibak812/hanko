<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/counter/

메인 카운터 화면

## Key Files

- `counter_screen.dart` - 메인 화면 (탭하면 카운터 증가)

## Widgets (widgets/)

| 위젯 | 역할 |
|------|------|
| `counter_display.dart` | 큰 숫자 표시 |
| `secondary_counter.dart` | 코/패턴 카운터 |
| `action_buttons.dart` | 하단 액션 버튼들 |
| `progress_header.dart` | 상단 진행률 바 |
| `memo_card.dart` | 메모 알림 카드 |
| `main_counter_button.dart` | +1 버튼 (현재 미사용) |

## User Interactions

- **화면 탭**: 단 카운터 +1
- **Progress Header 탭**: 프로젝트 목록으로 이동
- **음성 버튼**: 음성 명령 시작
- **더보기 버튼**: 하단 시트 메뉴

## For AI Agents

- 터치 영역은 ProgressHeader 아래부터 시작 (상단 제외)
- 햅틱 피드백: `HapticFeedback.mediumImpact()`
- 플래시 애니메이션으로 시각적 피드백
