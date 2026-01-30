# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run

# 정적 분석
flutter analyze

# ObjectBox 코드 생성 (모델 변경 시 필수)
dart run build_runner build

# 테스트 실행
flutter test

# 단일 테스트 실행
flutter test test/widget_test.dart
```

## Architecture Overview

Clean Architecture 기반 Flutter 앱 (뜨개질 카운터).

```
lib/
├── main.dart              # 진입점: SharedPreferences, ObjectBox 초기화
├── app.dart               # MaterialApp 설정, 테마/라우터 적용
├── core/                  # 공유 상수, 테마 (의존성 없음)
│   ├── constants/         # AppColors, AppStrings, VoiceCommands
│   └── theme/             # AppTheme (라이트/다크)
├── data/                  # 데이터 레이어
│   ├── models/            # ObjectBox Entity (@Entity 어노테이션)
│   ├── datasources/       # ObjectBoxDatabase, LocalStorage
│   └── repositories/      # ProjectRepository
├── domain/                # 비즈니스 로직
│   └── services/          # VoiceService, AdService, PremiumService
├── presentation/          # UI 레이어
│   ├── providers/         # Riverpod StateNotifier/Provider
│   ├── screens/           # 화면별 폴더 (counter/, projects/, settings/)
│   └── widgets/           # 공통 위젯
└── router/                # go_router 라우팅
```

**의존성 방향**: `presentation → domain → data → core`

## Key Patterns

**상태 관리 (Riverpod)**:
- 구독: `ref.watch(provider)` (rebuild 트리거)
- 읽기: `ref.read(provider)` (일회성)
- 액션: `ref.read(provider.notifier).method()`

**네비게이션 (go_router)**:
- 이동: `context.push(AppRoutes.settings)`
- 데이터 전달: `context.push(AppRoutes.projectSettings, extra: projectId)`

**ObjectBox 모델 수정 시**:
1. `@Entity()` 클래스 수정
2. `dart run build_runner build` 실행
3. `objectbox.g.dart` 자동 재생성 (직접 수정 금지)

## AGENTS.md Reference

각 디렉토리에 `AGENTS.md` 파일이 있습니다. 작업 전 해당 디렉토리의 AGENTS.md를 참조하세요.

| 작업 | 참조 |
|------|------|
| 색상/문자열 | `lib/core/constants/AGENTS.md` |
| 새 모델 | `lib/data/models/AGENTS.md` |
| 새 화면 | `lib/presentation/screens/AGENTS.md` |
| Provider | `lib/presentation/providers/AGENTS.md` |
| 라우트 | `lib/router/AGENTS.md` |

## Documentation (Ship 시 필수)

작업 완료 후 **문서화** 단계에서 다음 파일들을 업데이트하세요:

### 1. CHANGELOG.md
모든 변경사항을 `[Unreleased]` 섹션에 기록:
- **Added**: 새 기능, 새 파일
- **Changed**: 기존 기능 수정, 동작 변경
- **Removed**: 제거된 기능
- **Fixed**: 버그 수정
- **Dev**: 개발 환경 설정 변경

### 2. AGENTS.md (수정된 디렉토리)
코드 변경이 있었던 디렉토리의 AGENTS.md 업데이트:
- 새 파일 추가 시 → 해당 디렉토리 AGENTS.md에 파일 설명 추가
- 기존 파일 역할 변경 시 → 설명 업데이트
- 새 패턴/규칙 도입 시 → "For AI Agents" 섹션에 추가

### 3. CLAUDE.md (이 파일)
프로젝트 전체에 영향을 주는 변경 시:
- 새 명령어 추가 → Build & Development Commands
- 아키텍처 변경 → Architecture Overview
- 새 개발 설정 → Dev Notes

## Fastlane 배포

### Ruby 환경 (Homebrew Ruby 사용)

시스템 Ruby(2.6)는 호환성 문제가 있어 Homebrew Ruby를 사용합니다:

```bash
# Homebrew Ruby 경로
/opt/homebrew/opt/ruby/bin/ruby
/opt/homebrew/opt/ruby/bin/bundle

# iOS 배포
cd ios
/opt/homebrew/opt/ruby/bin/bundle install
/opt/homebrew/opt/ruby/bin/bundle exec fastlane beta

# Android 배포
cd android
/opt/homebrew/opt/ruby/bin/bundle install
/opt/homebrew/opt/ruby/bin/bundle exec fastlane internal
```

### 배포 Lane 요약

| 플랫폼 | Lane | 설명 |
|--------|------|------|
| iOS | `beta` | TestFlight 배포 |
| iOS | `release` | App Store 배포 |
| Android | `internal` | Google Play 내부 테스트 |
| Android | `beta` | Google Play 베타 트랙 |
| Android | `release` | Google Play 프로덕션 |

### 필요한 인증 파일

| 플랫폼 | 파일 | 설명 |
|--------|------|------|
| iOS | `~/.appstoreconnect/AuthKey_*.p8` | App Store Connect API Key |
| Android | `android/fastlane/play-store-credentials.json` | Google Play 서비스 계정 키 |
| Android | `android/key.properties` | 앱 서명 키스토어 정보 |

## Dev Notes

- 음성 제한: 개발용 999회 설정 (`lib/presentation/providers/app_providers.dart:109`)
- 기본 테마: 라이트 모드 (`lib/data/datasources/local_storage.dart:298`)
