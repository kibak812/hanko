<!-- Parent: ../AGENTS.md -->
# lib/data/repositories/

리포지토리 - 데이터 접근 추상화

## Key Files

- `project_repository.dart` - 프로젝트 CRUD

## ProjectRepository

```dart
final repo = ProjectRepository(db);

// CRUD
repo.getAll()
repo.getById(id)
repo.save(project)
repo.delete(project)

// 활성 프로젝트
repo.getActiveProject(localStorage)
repo.setActiveProject(project, localStorage)
```

## For AI Agents

- Repository는 ObjectBoxDatabase에 의존
- Provider에서 Repository를 주입받아 사용
