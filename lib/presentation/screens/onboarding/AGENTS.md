<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/onboarding/

온보딩 화면

## Key Files

- `onboarding_screen.dart` - 첫 실행 시 온보딩

## Features

- 앱 소개 (한코한코 로고 + 태그라인)
- 프리미엄 무료 체험 안내
- 첫 프로젝트 시작 버튼

## Flow

1. 앱 첫 실행 → 온보딩 화면
2. "시작하기" 클릭 → 새 프로젝트 화면
3. 프로젝트 생성 완료 → 메인 카운터 화면
4. 이후 실행 시 바로 카운터 화면

## For AI Agents

- 온보딩 완료: `localStorage.setOnboardingCompleted(true)`
- 라우터에서 `isOnboardingCompleted`로 초기 화면 결정
