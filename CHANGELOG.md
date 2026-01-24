# Changelog

모든 주요 변경사항을 이 파일에 기록합니다.

## [Unreleased]

### Added
- **RevenueCat 프리미엄 결제 시스템**
  - `PremiumService`: RevenueCat SDK 래핑 (초기화, 구매, 복원, 상태 확인)
  - `PremiumPurchaseSheet`: 프리미엄 구매 바텀시트 UI (월간/연간 구독 선택)
  - `premiumServiceProvider`: Riverpod Provider로 서비스 주입
  - 앱 시작 시 RevenueCat에서 구독 상태 자동 동기화
  - 프로젝트 제한 다이얼로그에서 구매 시트 연결
- **AdMob 광고 시스템 구현**
  - 배너 광고: 모든 화면 하단에 배치 (프리미엄 사용자 제외)
  - 전면 광고: 프로젝트 선택, 생성, 메모 저장 시 표시 (3분 간격, 세션당 5회 제한)
  - 리워드 광고: 음성 명령 제한 도달 시 광고 시청으로 +5회 추가
  - `AdBannerWidget` - 하단 배너 광고 위젯 (레이아웃 안정성 보장)
  - `InterstitialAdController` - 전면 광고 빈도 제어
  - `adServiceProvider`, `interstitialAdControllerProvider` 추가

### Changed
- **AdService 개선**
  - 프로덕션 광고 ID 추가 (iOS/Android)
  - `kReleaseMode`로 테스트/프로덕션 광고 자동 전환
  - 광고 로드 실패 시 최대 3회 재시도 후 중단
- `HankoHankoApp`을 `ConsumerStatefulWidget`으로 변경 (동기화 지원)
- 음성 명령 일일 제한: 999회(개발용) → 5회 (광고 시청 시 최대 10회)

### Changed
- **메인 카운터 UI 개선**
  - 프로젝트명 영역 위아래 간격 확대 (vertical padding 8 추가)
  - 우측 아이콘 변경: `chevron_right` → `menu` (햄버거 메뉴)
  - 날짜 앞 캘린더 아이콘 추가 (`calendar_today_outlined`)
  - 시간 앞 타이머 아이콘 추가 (`schedule_outlined`)
- **프로젝트 목록 시간 표시**: 초 단위까지 표시 (예: "2시간 30분 15초")
- **보조 카운터 완료 효과 개선**
  - 기존 bounce 애니메이션 → Subtle Glow 효과 (primary 색상)
  - Goal/Repetition 모두 파란색(primary)으로 통일
  - 우상단 체크마크 배지 제거
  - 인라인 편집기도 primary 색상으로 통일

### Added
- **Repetition 카운터 리셋 효과**: 리셋값 도달 시 5/5 표시 → 파란 플래시 → 0으로 변경
  - 리셋 중 최대값 잠시 표시 후 실제 값(0)으로 전환
  - primary 색상 플래시 + lightImpact 햅틱

### Removed
- 보조 카운터 목표 달성 다이얼로그 (`_showSecondaryGoalCompletedDialog`) 삭제
- 보조 카운터 자동 리셋 토스트 (`_showSecondaryAutoResetToast`) 삭제

### Added
- **프로젝트 카드 시간 정보 표시** - 시작일, 완료일, 누적 작업시간을 프로젝트 목록에서 확인
  - 진행 중: `1/5부터 · 2시간 30분`
  - 완료: `1/5 → 1/19 · 총 5시간 30분`
- **프로젝트 작업 시간 추적 기능**
  - 타이머 버튼: 탭으로 시작/정지, 롱프레스로 누적 시간 리셋
  - 정보 바 (`ProjectInfoBar`): ProgressHeader 아래에 시작일 + 작업시간 표시
  - 날짜 편집 바텀시트 (`DateEditSheet`): 시작일/완료일 편집 (정보 바 롱프레스)
  - 백그라운드 전환 시 타이머 자동 정지 (`WidgetsBindingObserver`)
  - 프로젝트 생성 시 startDate 자동 설정
  - 완료일 설정 시 프로젝트 상태 자동 완료 처리
- `Project` 모델에 `startDate`, `completedDate`, `totalWorkSeconds`, `timerStartedAt` 필드 추가
- 한국어 DatePicker 지원 (`flutter_localizations` 추가)

### Removed
- 프로젝트 카드 "활성" 배지 제거

### Changed
- 하단 액션 버튼 레이아웃 개선: `Flexible` + `AspectRatio`로 오버플로우 방지
- 버튼 크기 축소: 56x56 → 48x48 (최대), 간격 12px → 8px
- 메모 아이콘 변경: `note_alt_outlined` → `sticky_note_2_outlined`
- 정보 바 날짜 포맷: `2026/1/19부터 1분 30초째...`
- 작업시간 초 단위까지 표시

### Fixed
- 보조 카운터 제거 버그 수정: 확인 다이얼로그가 인라인 편집기 뒤에 가려지던 문제
- 보조 카운터 제거 후 UI 미갱신 문제 수정 (ObjectBox ToMany 관계 처리 순서 수정)

### Changed
- 메모 카드와 메인 카운터 사이 간격 추가 (20px)
- 메모 카드 배경색 진하게 변경 - 앱 배경과 구분 개선
- 메모 카드에 그림자 추가
- 보조 카운터 없을 때 추가 버튼 전체 너비로 표시 (높이 72px)
- 프로젝트명 옆 실뭉치 이모지(🧶) 제거 - 상단바, 프로젝트 카드, 인라인 편집기
- 새 프로젝트 생성 시 보조 카운터 방식 통일: 레거시(코/패턴) → 현재 방식(횟수/반복)
- `withOpacity()` → `withValues(alpha:)` 마이그레이션 (deprecated API 제거)

### Added
- 프로젝트 인라인 편집기 (`ProjectInlineEditor`) - 상단바 롱프레스 시 프로젝트명/목표 단수 편집
- 보조 카운터 목표 달성 시 체크마크 배지 (우상단 원형)
- 보조 카운터 목표 달성 시 펄스 애니메이션 (2초간)
- 보조 카운터 목표 달성 시 더블 탭 햅틱 피드백
- `getWidgetRect()` BuildContext extension - 위젯 Rect 가져오기 공통화
- 보조 카운터 추가 버튼 (`AddCounterButton`) - 메인 화면 그리드에 "+" 버튼 통합
- 인라인 카운터 편집기 (`InlineCounterEditor`) - 롱프레스 시 화면 중앙에 편집 카드 표시
- 메모 버튼 액션바에 추가 - 빠른 메모 접근
- 보조 카운터 메인 연동 기능 (`isLinked` 필드) - 메인 카운터 증감 시 연동된 보조 카운터도 함께 변경
- 보조 카운터 타입 아이콘 - Goal(깃발), Repetition(회전 화살표)
- 보조 카운터 연동 토글 UI - 우상단 링크 아이콘 탭으로 연동 on/off
- `LargeAreaButton` 공통 위젯 - 카운터 하단 +/- 버튼 통합
- `showRemoveCounterDialog` 공통 함수 - 카운터 제거 확인 다이얼로그
- `AppColorsExtension` - 다크 모드 색상 접근용 BuildContext extension
- **동적 보조 카운터 시스템** - 반복(주기) / 횟수(목표) 두 가지 유형
- 보조 카운터 추가 바텀시트 (`AddSecondaryCounterSheet`)
- 보조 카운터 마이그레이션 유틸 (`migration_utils.dart`) - 기존 코/패턴 카운터 자동 변환
- `SecondaryCounterType` enum (repetition, goal)
- `Counter` 모델에 `secondaryTypeIndex`, `orderIndex` 필드 추가
- `Project` 모델에 `secondaryCounters` ToMany 관계 추가
- 공통 카운터 히스토리 (`CounterAction`) - 모든 카운터(단/코/패턴/보조) 되돌리기 지원
- 메인 카운터 인라인 +/- 버튼 (`CounterDisplay`)
- 보조 카운터 인라인 +/- 버튼 및 `onDecrement` 콜백
- `decrementPattern()` 메서드 (Repository, Provider)
- 보조 카운터 기능 완성: 코 카운터 목표값, 패턴 자동 리셋
- 카운터 설정 바텀시트 (`CounterSettingsSheet`) - 롱프레스로 열기, 라벨 편집 지원
- 확장형 카운터 옵션 위젯 (`ExpandableCounterOption`)
- SVG 아이콘 시스템 (`AppIcons`) - 코/패턴/목표 아이콘
- 목표 달성 다이얼로그 및 자동 리셋 토스트 알림
- 프로젝트 편집 시 보조 카운터 추가/제거 기능
- `flutter_svg` 의존성 추가
- 설정 화면 (`AppSettingsScreen`) - 햅틱/음성 피드백, 화면 유지, 테마 선택
- `/settings` 라우트 추가
- `package_info_plus` 의존성 추가 (버전 정보 표시)
- 음성 리밋 도달 시 스낵바 안내 메시지
- 프로젝트 전체 AGENTS.md 문서화 (19개 파일)
- CLAUDE.md 프로젝트 가이드
- `vibration` 패키지 추가 (안드로이드 햅틱 피드백 개선)
- 메모 목록 화면 (`MemoListScreen`) 및 `/memos` 라우트

### Changed
- **완료 색상 변경**: 연두색(#6BCB77) → 골든 허니(#D4A574) - 따뜻한 톤으로 통일
- **더보기 메뉴 → 설정 버튼**: 팝업 메뉴 제거, 설정 아이콘 버튼으로 단순화
- 상단 헤더에 롱프레스 편집 기능 추가
- 인라인 편집기 키보드 UX 개선: 배경 탭 시 키보드만 닫기, 키보드 겹침 회피
- 더보기 메뉴 PopupMenuButton으로 변경 (바텀시트 → 팝업 메뉴)
- 보조 카운터 그리드 레이아웃 개선 (IntrinsicHeight로 높이 매칭)
- 보조 카운터 편집 방식 변경: 바텀시트 → 인라인 확대 편집
- 보조 카운터 진행률 표시 위치 변경: 우상단 텍스트 → 숫자 오른쪽 하단 (`2 /4` 형태)
- 햅틱 피드백 로직 리팩토링: `_triggerHaptic`, `_triggerDoubleHaptic` 헬퍼 메서드
- 코드 중복 142줄 제거 (LargeAreaButton, 다이얼로그, 햅틱 피드백)
- VoidCallback 재정의 제거 → Flutter 내장 타입 사용
- **메인 카운터 UI 리디자인**: 상단 70% 숫자영역, 하단 30% -/+ 버튼 분리
- **보조 카운터 UI 리디자인**: 상단 라벨 + 진행률 바, 하단 -/+ 버튼
- 카운터 히스토리 JSON 파서를 `dart:convert` 표준 라이브러리로 교체 (되돌리기 버그 수정)
- 카운터 조작 UX 통일: 모든 카운터에 인라인 +/- 버튼 적용
- 화면 탭으로 카운터 증가 기능 제거 (명시적 버튼 조작으로 변경)
- 보조 카운터: 탭(+1) 제거 → 인라인 +/- 버튼으로 조작
- 하단 ActionButtons: -1 버튼 제거 (각 카운터에 인라인 버튼으로 대체)
- 보조 카운터 터치 반응 즉시 반응으로 개선 (더블탭 감지 대기 제거)
- 보조 카운터 제스처: 탭(+1), 롱프레스(설정)
- 보조 카운터 UI: 진행률 바, 목표값 표시 추가
- 터치 영역에서 ProgressHeader 제외 (실수로 카운터 증가 방지)
- 기본 테마를 라이트 모드로 변경 (`system` → `light`)
- Secondary 색상: 민트(#4ECDC4) → 테라코타(#E07A5F)
- Background 색상: #FFFBF0 → #FAF3E0 (카드와 명확한 대비)
- 메모 카드 UI: 💡 이모지 → 핀 아이콘, 배경색 베이지 톤으로 변경
- iOS 최소 배포 타겟 15.0으로 업그레이드 (ObjectBox 요구사항)
- 음성 인식 연속 모드 개선: 명령 후 자동 재시작, 타임아웃 후 자동 재연결
- 음성 인식 iOS 대응: 부분 결과에서 명령어 감지, dictation 모드 사용
- 햅틱 피드백: 안드로이드에서 Vibration 패키지 사용 (더 확실한 진동)
- 화면 유지(WakeLock) 기능 실제 구현 (기존에는 설정만 있고 미작동)
- 새 프로젝트 생성 후 메인 화면으로 이동 (온보딩에서 저장 시 작동 안하던 버그 수정)
- 액션 버튼 UI 미니멀화: 텍스트 레이블 제거, 아이콘만 표시

### Fixed
- 되돌리기 버튼 비활성화 버그 수정 (커스텀 JSON 파서 → dart:convert로 교체)
- 메인 화면 레이아웃 패딩 문제 수정 (Spacer 제거)
- 보조 카운터 삭제 시 UI 즉시 반영 안되는 문제 수정

### Removed
- 메인 +1 버튼 제거 (화면 탭으로 대체)
- 마일스톤 토스트 알림 제거 (10단 단위)
- 음성 피드백(TTS) 기능 제거
- 설정에서 "음성 피드백" 옵션 제거

### Dev
- 보조 카운터 제한 999개로 변경 (개발용)

---

## [1.0.0] - 초기 버전

### Added
- 메인 카운터 화면 (단/코/패턴)
- 프로젝트 관리 (생성/편집/삭제)
- 음성 인식 명령어 지원
- 라이트/다크 테마
- ObjectBox 로컬 데이터베이스
- 온보딩 화면
