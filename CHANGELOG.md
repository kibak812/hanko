# Changelog

모든 주요 변경사항을 이 파일에 기록합니다.

## [Unreleased]

### Added
- 설정 화면 (`AppSettingsScreen`) - 햅틱/음성 피드백, 화면 유지, 테마 선택
- `/settings` 라우트 추가
- `package_info_plus` 의존성 추가 (버전 정보 표시)
- 음성 리밋 도달 시 스낵바 안내 메시지
- 프로젝트 전체 AGENTS.md 문서화 (19개 파일)
- CLAUDE.md 프로젝트 가이드

### Changed
- 터치 영역에서 ProgressHeader 제외 (실수로 카운터 증가 방지)
- 기본 테마를 라이트 모드로 변경 (`system` → `light`)
- Secondary 색상: 민트(#4ECDC4) → 테라코타(#E07A5F)
- Background 색상: #FFFBF0 → #FAF3E0 (카드와 명확한 대비)
- 메모 카드 UI: 💡 이모지 → 핀 아이콘, 배경색 베이지 톤으로 변경

### Removed
- 메인 +1 버튼 제거 (화면 탭으로 대체)

### Dev
- 음성 제한 999회로 변경 (개발용)

---

## [1.0.0] - 초기 버전

### Added
- 메인 카운터 화면 (단/코/패턴)
- 프로젝트 관리 (생성/편집/삭제)
- 음성 인식 명령어 지원
- 라이트/다크 테마
- ObjectBox 로컬 데이터베이스
- 온보딩 화면
