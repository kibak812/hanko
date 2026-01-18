<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/counter/

메인 카운터 화면

## Key Files

- `counter_screen.dart` - 메인 화면 (탭하면 카운터 증가)

## Widgets (widgets/)

| 위젯 | 역할 |
|------|------|
| `counter_display.dart` | 큰 숫자 표시 |
| `secondary_counter.dart` | 보조 카운터 (탭: +1, 롱프레스: 인라인 편집) |
| `add_counter_button.dart` | 보조 카운터 추가 버튼 (점선 + 아이콘) |
| `inline_counter_editor.dart` | 인라인 확대 편집기 (Overlay 기반) |
| `counter_settings_sheet.dart` | 카운터 설정 바텀시트 |
| `action_buttons.dart` | 하단 액션 버튼들 (되돌리기, 메모, 타이머, 음성, 설정) |
| `progress_header.dart` | 상단 진행률 바 |
| `project_info_bar.dart` | 프로젝트 정보 바 (시작일 + 작업시간, 실시간 업데이트) |
| `date_edit_sheet.dart` | 날짜 편집 바텀시트 (시작일/완료일) |
| `memo_card.dart` | 메모 알림 카드 |
| `main_counter_button.dart` | +1 버튼 (현재 미사용) |

## User Interactions

- **Progress Header 탭**: 프로젝트 목록으로 이동
- **Progress Header 롱프레스**: 프로젝트 인라인 편집기
- **정보 바 롱프레스**: 날짜 편집 바텀시트
- **보조 카운터 탭**: 보조 카운터 +1
- **보조 카운터 롱프레스**: 인라인 편집기 열기
- **"+" 버튼 탭**: 보조 카운터 추가 바텀시트
- **메모 버튼**: 메모 목록 화면으로 이동
- **타이머 버튼 탭**: 타이머 시작/정지
- **타이머 버튼 롱프레스**: 누적 작업시간 리셋
- **음성 버튼**: 음성 명령 시작
- **설정 버튼**: 설정 화면으로 이동

## For AI Agents

- 터치 영역은 ProgressHeader 아래부터 시작 (상단 제외)
- 햅틱 피드백: `HapticFeedback.mediumImpact()`
- 플래시 애니메이션으로 시각적 피드백
- 보조 카운터는 `onTapDown`에서 즉시 증가 (더블탭 감지 대기 없음)
- 목표 달성 시 다이얼로그, 자동 리셋 시 토스트 표시
- 인라인 편집기는 Overlay로 표시, 배경 탭 시 자동 저장 후 닫힘
- 보조 카운터 그리드는 IntrinsicHeight + Row로 높이 매칭
- 타이머는 `WidgetsBindingObserver`로 백그라운드 전환 감지하여 자동 정지
- 정보 바는 타이머 실행 중일 때 매초 UI 업데이트 (`Timer.periodic`)
- 하단 버튼은 `Flexible` + `AspectRatio`로 화면 크기에 따라 자동 조절
