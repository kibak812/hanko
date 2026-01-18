# 한코한코 (Hanko Hanko)

뜨개질 카운터 Flutter 앱 - 한국어 음성 제어와 위젯으로 편리한 카운팅

## Project Overview

| 항목 | 값 |
|------|-----|
| 언어 | Dart/Flutter |
| 상태관리 | Riverpod |
| 로컬 DB | ObjectBox |
| 라우팅 | go_router |
| 수익화 | Google AdMob + RevenueCat |

## Directory Structure

```
lib/
├── core/           # 상수, 테마, 유틸리티
├── data/           # 데이터 레이어 (모델, DB, 리포지토리)
├── domain/         # 비즈니스 로직 (서비스)
├── presentation/   # UI 레이어 (화면, 위젯, Provider)
├── router/         # 네비게이션 라우팅
├── main.dart       # 앱 진입점
└── app.dart        # MaterialApp 설정
```

## Key Files (Root)

- `lib/main.dart` - 앱 초기화 및 Provider 설정
- `lib/app.dart` - MaterialApp, 테마, 라우터 설정
- `lib/objectbox.g.dart` - ObjectBox 자동 생성 파일 (수정 금지)
- `pubspec.yaml` - 의존성 관리

## For AI Agents

### 코딩 컨벤션
- **상태관리**: `ref.watch()`로 상태 구독, `ref.read()`로 액션 실행
- **네비게이션**: `context.push(AppRoutes.xxx)` 사용
- **색상/문자열**: `AppColors`, `AppStrings` 상수 사용
- **다크모드**: `Theme.of(context).brightness` 확인 후 조건 분기

### 빌드 명령
```bash
flutter pub get          # 의존성 설치
flutter analyze          # 정적 분석
flutter run              # 앱 실행
dart run build_runner build  # ObjectBox 코드 생성
```

### 중요 주의사항
- `objectbox.g.dart`는 자동 생성 파일 - 직접 수정 금지
- 모델 변경 시 `dart run build_runner build` 실행 필요
- 음성 제한은 현재 개발용으로 999회 설정됨 (`app_providers.dart:109`)

## Subdirectories

- `lib/` - 메인 소스 코드 (see lib/AGENTS.md)
- `assets/` - 폰트, 아이콘, 이미지, 사운드
- `android/` - Android 플랫폼 설정
- `ios/` - iOS 플랫폼 설정
- `test/` - 테스트 코드
