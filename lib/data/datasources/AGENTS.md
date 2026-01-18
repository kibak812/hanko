<!-- Parent: ../AGENTS.md -->
# lib/data/datasources/

데이터 소스 - DB 및 로컬 저장소

## Key Files

| 파일 | 역할 |
|------|------|
| `objectbox_database.dart` | ObjectBox Store 관리 |
| `local_storage.dart` | SharedPreferences 래퍼 + AppSettings 모델 |

## ObjectBoxDatabase

```dart
final db = ObjectBoxDatabase();
await db.init();

db.projectBox  // Box<Project>
db.memoBox     // Box<RowMemo>
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
