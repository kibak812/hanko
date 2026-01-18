<!-- Parent: ../AGENTS.md -->
# lib/

Flutter 앱 메인 소스 코드 디렉토리

## Purpose

한코한코 앱의 모든 Dart 소스 코드가 위치. Clean Architecture 기반 레이어 분리.

## Architecture

```
┌─────────────────────────────────────────┐
│           presentation/                  │  UI Layer
│   (screens, widgets, providers)          │
├─────────────────────────────────────────┤
│              domain/                     │  Business Logic
│            (services)                    │
├─────────────────────────────────────────┤
│               data/                      │  Data Layer
│   (models, datasources, repositories)    │
├─────────────────────────────────────────┤
│               core/                      │  Shared
│    (constants, theme, utils)             │
└─────────────────────────────────────────┘
```

## Key Files

- `main.dart` - 앱 진입점, SharedPreferences/ObjectBox 초기화
- `app.dart` - MaterialApp 설정, 테마/라우터 적용
- `objectbox.g.dart` - ObjectBox 자동 생성 (수정 금지)

## Subdirectories

- `core/` - 상수, 테마, 유틸리티 (see core/AGENTS.md)
- `data/` - 데이터 모델, DB, 리포지토리 (see data/AGENTS.md)
- `domain/` - 비즈니스 서비스 (see domain/AGENTS.md)
- `presentation/` - UI 화면, 위젯, Provider (see presentation/AGENTS.md)
- `router/` - 네비게이션 라우팅 (see router/AGENTS.md)

## For AI Agents

### 파일 생성 규칙
- 새 화면: `presentation/screens/{feature}/{feature}_screen.dart`
- 새 위젯: `presentation/screens/{feature}/widgets/{widget_name}.dart`
- 새 모델: `data/models/{model_name}.dart` + models.dart에 export 추가
- 새 서비스: `domain/services/{service_name}.dart`

### 의존성 방향
```
presentation → domain → data → core
      ↓           ↓        ↓
    (UI)    (Business)  (Data)
```
- 상위 레이어가 하위 레이어에만 의존
- core는 어디서든 import 가능
