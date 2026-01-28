<!-- Parent: ../AGENTS.md -->
# lib/presentation/screens/onboarding/

온보딩 및 튜토리얼 화면

## Key Files

- `onboarding_screen.dart` - 첫 실행 시 온보딩 (튜토리얼 시작 버튼 포함)
- `tutorial_screen.dart` - 인터랙티브 튜토리얼 화면

### widgets/
- `tutorial_overlay.dart` - 스포트라이트 오버레이 (CustomPainter)
- `tutorial_tooltip.dart` - 튜토리얼 말풍선 UI + 롱프레스 힌트 애니메이션
- `tutorial_celebration.dart` - 튜토리얼 완료 축하 애니메이션 (컨페티)

## Tutorial Flow

1. 온보딩 화면 → "기능 둘러보기" 선택
2. 튜토리얼 화면 (데모 프로젝트 자동 생성)
3. Step 1: ProgressHeader 롱프레스 (프로젝트명/목표)
4. Step 2: ProjectInfoBar 롱프레스 (시작일/완료일)
5. Step 3: SecondaryCounter 롱프레스 (보조 카운터 편집)
6. Step 4: Timer 버튼 롱프레스 (작업 시간 리셋)
7. Step 5: Voice 버튼 탭 (음성 명령 안내)
8. 완료 화면 → 첫 프로젝트 시작

## For AI Agents

- 튜토리얼 상태 관리: `tutorial_provider.dart`
- 튜토리얼 완료: `localStorage.setTutorialCompleted(true)`
- 튜토리얼 다시 보기: 설정 화면에서 `tutorialProvider.notifier.resetTutorial()`
- 데모 프로젝트: 튜토리얼 시작 시 자동 생성, 완료/스킵 시 자동 삭제
