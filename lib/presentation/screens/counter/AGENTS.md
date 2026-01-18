<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/counter/

메인 카운터 화면

## Key Files

- `counter_screen.dart` - 메인 화면 (탭하면 카운터 증가)

## Widgets (widgets/)

| 위젯 | 역할 |
|------|------|
| `counter_display.dart` | 큰 숫자 표시 |
| `secondary_counter.dart` | 코/패턴 카운터 (탭: +1, 롱프레스: 설정) |
| `counter_settings_sheet.dart` | 카운터 설정 바텀시트 |
| `action_buttons.dart` | 하단 액션 버튼들 |
| `progress_header.dart` | 상단 진행률 바 |
| `memo_card.dart` | 메모 알림 카드 |
| `main_counter_button.dart` | +1 버튼 (현재 미사용) |

## User Interactions

- **화면 탭**: 단 카운터 +1
- **Progress Header 탭**: 프로젝트 목록으로 이동
- **보조 카운터 탭**: 코/패턴 카운터 +1
- **보조 카운터 롱프레스**: 설정 바텀시트 열기
- **음성 버튼**: 음성 명령 시작
- **더보기 버튼**: 하단 시트 메뉴

## For AI Agents

- 터치 영역은 ProgressHeader 아래부터 시작 (상단 제외)
- 햅틱 피드백: `HapticFeedback.mediumImpact()`
- 플래시 애니메이션으로 시각적 피드백
- 보조 카운터는 `onTapDown`에서 즉시 증가 (더블탭 감지 대기 없음)
- 목표 달성 시 다이얼로그, 자동 리셋 시 토스트 표시
