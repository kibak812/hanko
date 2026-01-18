<!-- Parent: ../AGENTS.md -->
# lib/data/

데이터 레이어 - 모델, 데이터소스, 리포지토리

## Purpose

앱의 모든 데이터 관련 코드. ObjectBox DB 연동, 로컬 저장소 관리.

## Subdirectories

- `models/` - 데이터 모델 (ObjectBox Entity) (see models/AGENTS.md)
- `datasources/` - DB 및 로컬 저장소 (see datasources/AGENTS.md)
- `repositories/` - 데이터 접근 추상화 (see repositories/AGENTS.md)

## For AI Agents

### 새 모델 추가 시
1. `models/` 폴더에 파일 생성
2. `@Entity()` 어노테이션 사용
3. `models/models.dart`에 export 추가
4. `dart run build_runner build` 실행

### ObjectBox 규칙
- ID 필드: `int id = 0` (0이면 자동 생성)
- 관계: `ToOne<T>`, `ToMany<T>` 사용
- 인덱스: `@Index()` 어노테이션
