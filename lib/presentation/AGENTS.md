<!-- Parent: ../AGENTS.md -->
# lib/presentation/

프레젠테이션 레이어 - UI 화면, 위젯, 상태관리

## Purpose

사용자에게 보이는 모든 UI 코드. Riverpod Provider로 상태 관리.

## Subdirectories

- `screens/` - 각 화면별 폴더 (see screens/AGENTS.md)
- `providers/` - Riverpod Provider 정의 (see providers/AGENTS.md)
- `widgets/` - 공통 위젯 (see widgets/AGENTS.md)

## Screen Structure

```
screens/
├── counter/          # 메인 카운터 화면
│   ├── counter_screen.dart
│   └── widgets/      # 화면 전용 위젯
├── projects/         # 프로젝트 목록
├── settings/         # 설정 화면들
└── onboarding/       # 온보딩
```

## For AI Agents

### 화면 작성 규칙
1. `ConsumerWidget` 또는 `ConsumerStatefulWidget` 사용
2. 상태 읽기: `ref.watch(provider)`
3. 액션 실행: `ref.read(provider.notifier).method()`
4. 네비게이션: `context.push(AppRoutes.xxx)`

### 위젯 분리 기준
- 100줄 이상이면 별도 위젯으로 분리
- 재사용 가능하면 `widgets/` 폴더로
- 화면 전용이면 `screens/{feature}/widgets/` 폴더로
