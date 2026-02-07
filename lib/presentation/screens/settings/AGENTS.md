<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/settings/

설정 화면들

## Key Files

| 파일 | 화면 | 설명 |
|------|------|------|
| `app_settings_screen.dart` | AppSettingsScreen | 앱 전체 설정 |
| `project_settings_screen.dart` | ProjectSettingsScreen | 프로젝트 생성/편집 |

## AppSettingsScreen

설정 항목:
- 햅틱 피드백 (Switch)
- 화면 유지 (Switch)
- 테마 (SegmentedButton: 라이트/다크/시스템)
- 튜토리얼 다시 보기
- 데이터 백업 (JSON 파일 공유)
- 데이터 복원 (파일 선택 → 검증 → 확인 → 덮어쓰기)
- 앱 정보 (버전)

## ProjectSettingsScreen

- 프로젝트 이름
- 목표 단수
- 코 카운터 목표 (선택)
- 패턴 반복 목표 (선택)

## For AI Agents

- 설정 변경: `ref.read(appSettingsProvider.notifier).setXxx(value)`
- 프로젝트 저장: `ref.read(projectListProvider.notifier).save(project)`
