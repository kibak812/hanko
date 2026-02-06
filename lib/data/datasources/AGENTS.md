<!-- Parent: ../AGENTS.md -->
# lib/data/datasources/

데이터 소스 - DB 및 로컬 저장소

## Key Files

| 파일 | 역할 |
|------|------|
| `objectbox_database.dart` | ObjectBox Store 관리 (단순 CRUD + 트랜잭션 일괄 저장) |
| `local_storage.dart` | SharedPreferences 래퍼 + AppSettings 모델 |
| `migration_utils.dart` | 데이터 마이그레이션 (v2: stitch/pattern -> secondaryCounters) |

## ObjectBoxDatabase

```dart
final db = ObjectBoxDatabase();
await db.init();

db.projectBox  // Box<Project>
db.memoBox     // Box<RowMemo>

// 단순 저장 (프로젝트 엔티티만)
db.saveProject(project)

// 트랜잭션 일괄 저장 (프로젝트 + 카운터 + 메모)
db.saveProjectWithRelations(project)
```

## LocalStorage

```dart
final storage = LocalStorage(prefs);

// 설정
storage.loadSettings()
storage.saveSettings(settings)

// 음성 사용량
storage.getTodayVoiceUsage()
storage.incrementVoiceUsage()

// 프리미엄
storage.getCachedPremiumStatus()
```

## For AI Agents

- ObjectBox는 비동기 초기화 필요 (`main.dart`에서)
- SharedPreferences도 비동기 초기화 필요
