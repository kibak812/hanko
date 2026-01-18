<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/projects/

프로젝트 목록 화면

## Key Files

- `project_list_screen.dart` - 프로젝트 목록

## Widgets (widgets/)

- `project_card.dart` - 프로젝트 카드 (진행률 표시)

## Features

- 모든 프로젝트 목록 표시
- 프로젝트 선택 시 활성 프로젝트 변경
- 새 프로젝트 추가 버튼
- 프로젝트 편집/삭제

## For AI Agents

- 프로젝트 선택: `ref.read(activeProjectProvider.notifier).setActive(project)`
- 프로젝트 삭제: `ref.read(projectListProvider.notifier).delete(project)`
