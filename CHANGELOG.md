# Changelog

모든 주요 변경사항을 이 파일에 기록합니다.

## [Unreleased]

### Added
- **데이터 백업/복원 기능**: 설정 화면에서 JSON 파일 기반 수동 백업/복원 지원
  - `BackupService`: 전체 데이터 JSON 직렬화, 파일 생성, 유효성 검증, 복원
  - `backup_serialization.dart`: Counter/RowMemo/Project extension 메서드로 직렬화/역직렬화
  - 백업 내보내기: 시스템 공유 시트(share_plus)로 JSON 파일 공유
  - 백업 가져오기: 파일 선택(file_picker) → 검증 → 확인 다이얼로그 → 전체 덮어쓰기 복원
  - 10MB 파일 크기 제한, 스키마 버전 검증, enum 범위 보정
  - 복원 시 counterHistoryJson 초기화 (ID 불일치 방지), timerStartedAt 세션 합산 후 제외
- `share_plus`, `file_picker` 의존성 추가
- `backupServiceProvider` Provider 추가
- 백업/복원 관련 AppStrings 상수 13개 추가
- **백업/복원 단위 테스트 41개**: 직렬화 round-trip, 검증 로직, enum 범위 보정 등
- **테스트 인프라 구축**: 164개 테스트로 핵심 비즈니스 로직 안전망 확보
  - `test/helpers/` - 테스트 팩토리, Mock 클래스, Widget test 공통 하네스
  - `test/core/utils/formatters_test.dart` - 시간/날짜 포맷팅 함수 테스트 (12개)
  - `test/data/models/` - Counter, Project, AppSettings 모델 테스트 (68개)
  - `test/presentation/providers/` - ProjectsNotifier, ActiveProjectCounterNotifier, AppSettingsNotifier 테스트 (61개)
  - `test/presentation/screens/` - ProjectListScreen, ProjectCard 위젯 테스트 (16개)
  - `test/presentation/widgets/` - ProgressIndicatorBar 위젯 테스트 (7개)
- `mocktail` 테스트 의존성 추가 (코드 생성 불필요 mock 라이브러리)
- **ProgressIndicatorBar 공통 위젯**: ProgressHeader와 ProjectCard에서 공유하는 진행률 바 위젯 추출
- **formatters.dart 공통 유틸**: 날짜/시간 포맷팅 함수 3개 (`formatDuration`, `formatDateFull`, `formatDateCompact`)
- **AppSettings 모델 분리**: `local_storage.dart`에서 `AppSettings` 클래스를 독립 파일로 분리
- **AppStrings 상수 25개 추가**: 동적 문자열 메서드 포함 (`stitchGoalCompleted`, `patternAutoReset`, `deleteProjectConfirmNamed`, `rowCompleted`)

### Changed
- **광고 ID dart-define 분리**: 하드코딩된 프로덕션 AdMob ID 6개를 `--dart-define`으로 주입, 테스트 ID를 기본값으로 설정
- **AdService Timer 안전성 강화**: `_isDisposed` 가드 추가, 성공 로드 시 retry Timer cancel
- **Future.delayed -> Timer 전환**: `ad_service.dart`, `voice_provider.dart`에서 `Timer` + dispose cancel 패턴으로 전환
- **VoiceStateNotifier dispose 추가**: `_retryTimer?.cancel()` 호출로 리소스 누수 방지
- **isDark 분기 30회+ -> context extension**: 15개+ presentation 파일에서 `isDark` 수동 분기를 `context.textPrimary`, `context.surface` 등으로 대체
- **하드코딩 문자열 -> AppStrings**: 11개 presentation 파일에서 한국어 문자열을 `AppStrings` 상수로 교체
- **CounterScreen Consumer 최적화**: voiceState watch를 ActionButtons만 Consumer로 감싸 불필요한 리빌드 제거
- **ProjectCounterState 레거시 필드 정리**: 미사용 5개 필드 제거 (`currentStitch`, `currentPattern` 등)
- **counterHistoryJson 캐싱**: `@Transient` 캐시 + dirty 플래그로 불필요한 JSON 파싱/직렬화 제거
- **Project.status @Index 추가**: 프로젝트 상태별 쿼리 성능 최적화
- **ProjectCard/ProjectInfoBar 공통화**: 중복 날짜/시간 포맷팅 로직을 `formatters.dart`로 추출
- **catch 에러 무시 -> debugPrint 로깅**: `local_storage.dart` 8곳의 빈 catch에 디버그 로깅 추가
- **Fastlane --dart-define 추가**: iOS/Android Fastfile에 광고 ID dart-define 파라미터 전달

### Fixed
- **프로젝트 목록 진입 시 StateNotifier 에러**: `initState`에서 동기적 `refresh()` 호출이 빌드 중 state 변경을 유발하는 문제 수정 (`Future.microtask`로 지연)
- **이모지 제거 (No Emoji Policy)**: counter_screen, project_list_screen, project_card, onboarding_screen의 이모지를 Material Icons로 교체
- **VoiceService 메모리 누수**: 콜백 참조(`_currentOnDone`/`_currentOnError`)가 정상 종료 시 해제되지 않던 문제 수정
- **main() 에러 핸들링 부재**: `runZonedGuarded` + `FlutterError.onError` + try-catch 추가로 초기화 실패 시 앱 크래시 방지
- **MigrationUtils 안전성 강화**: 프로젝트별 try-catch로 한 프로젝트 실패 시 나머지 계속 진행, 전체 성공 시에만 완료 플래그 설정
- **DB/Repository 저장 로직 이중 저장**: `ObjectBoxDatabase.saveProject()` 단순화 + `saveProjectWithRelations()` 트랜잭션 저장 추가
- **MemoCard 하드코딩 색상 상수화**: 6개 Color 리터럴을 `AppColors` + `AppColorsExtension`으로 이동
- **providers.dart barrel export**: `tutorial_provider.dart` export 추가

---

## [1.0.2] - App Store 심사 제출

### Added
- **Fastlane 배포 자동화**: iOS/Android 앱 스토어 배포 자동화 설정
  - iOS: TestFlight 베타, App Store 릴리즈 레인
  - Android: 내부 테스트, 베타, 프로덕션 레인
  - Gemfile로 Ruby 의존성 관리
- **app-ads.txt**: AdMob 광고 인벤토리 인증 파일 추가
- **인터랙티브 온보딩 튜토리얼**: 첫 사용자를 위한 앱 기능 안내
  - 5단계 튜토리얼: 프로젝트 편집, 날짜 편집, 보조 카운터 편집, 타이머 리셋, 음성 명령
  - 스포트라이트 오버레이 + 툴팁 UI로 대상 위젯 강조
  - 데모 프로젝트 자동 생성/삭제
  - 설정에서 "튜토리얼 다시 보기" 옵션 추가
- **앱 아이콘 디자인**: Apple 스타일의 미니멀한 V 스티치 아이콘

### Changed
- **무료 + 광고 모델로 전환**: 프리미엄 구독 → 완전 무료 (광고 수익 모델)
  - 프로젝트/보조 카운터 개수 무제한
  - 음성 명령 무제한 (5회마다 리워드 광고)
- **첫 프로젝트 생성 시 광고 제외**: 온보딩 경험 개선
- **스크린샷 교체**: 5장 -> 4장 (progress 제거), 새 디자인 적용
- **Fastfile 개선**: `upload_screenshots`, `submit_review` lane에 `app_version` 옵션 추가

### Removed
- **RevenueCat 프리미엄 시스템 완전 제거**
- **미사용 패키지 제거**: `cupertino_icons`, `uuid`, `flutter_animate`

### Fixed
- **메모 삭제 시 ObjectBox 에러 수정** (404 에러)
- **카운터 탭 성능 개선**: 개별 프로젝트만 갱신하도록 변경
- **메모 화면 버그 수정**: 다른 프로젝트의 메모가 표시될 수 있던 문제
- **프로젝트 설정 편집 버그 수정**: 목표 단수 저장 안 되던 문제
- **Deprecated API 전면 교체** (`withOpacity`, `activeColor` 등)
- **Lint 경고 해결**: `dart analyze` 통과

### Dev
- CLAUDE.md에 Fastlane 배포 가이드 및 iOS 배포 주의사항 추가

---

## [1.0.1] - RevenueCat + AdMob

### Added
- **AdMob 광고 시스템 구현**
  - 배너 광고: 모든 화면 하단에 배치
  - 전면 광고: 프로젝트 선택, 생성 시 표시 (3분 간격, 세션당 5회 제한)
  - 리워드 광고: 음성 명령 보너스 획득용
  - `AdBannerWidget` - 하단 배너 광고 위젯 (레이아웃 안정성 보장)
  - `InterstitialAdController` - 전면 광고 빈도 제어
  - `adServiceProvider`, `interstitialAdControllerProvider` 추가

### Changed
- **AdService 개선**
  - 프로덕션 광고 ID 추가 (iOS/Android)
  - `kReleaseMode`로 테스트/프로덕션 광고 자동 전환
  - 광고 로드 실패 시 최대 3회 재시도 후 중단

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
