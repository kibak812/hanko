<!-- Parent: ../AGENTS.md -->
# lib/data/models/

ObjectBox 데이터 모델 (Entity)

## Key Files

| 파일 | 모델 | 설명 |
|------|------|------|
| `project.dart` | Project | 뜨개질 프로젝트 |
| `counter.dart` | Counter | 단/코/패턴 카운터 |
| `row_memo.dart` | RowMemo | 특정 단에 메모 |
| `app_settings.dart` | AppSettings | 앱 설정 (테마, 햅틱, 화면유지 등) |
| `backup_serialization.dart` | - | Counter/RowMemo/Project 백업 직렬화 extension + fromBackupJson 헬퍼 |
| `models.dart` | - | 모든 모델 export |

## Project Model

```dart
@Entity()
class Project {
  int id = 0;
  String name;
  DateTime createdAt;

  final rowCounter = ToOne<Counter>();
  final stitchCounter = ToOne<Counter>();
  final patternCounter = ToOne<Counter>();
  final memos = ToMany<RowMemo>();
}
```

## For AI Agents

### 모델 수정 시
1. `@Entity()` 클래스 수정
2. `dart run build_runner build` 실행
3. `objectbox.g.dart` 재생성 확인

### 관계 정의
- 1:1 → `ToOne<T>`
- 1:N → `ToMany<T>`
