# iOS Release Pipeline (Fastlane)

한코한코 iOS 배포 표준 절차입니다.

## 목표
- 업로드 전 필수 검증 실패를 조기 차단
- 업로드/심사 제출을 1회 커맨드로 실행
- Apple 처리 지연 메시지를 실패와 구분

## 표준 커맨드

### 1) 사전 점검
```bash
cd ios
fastlane ios preflight app_version:X.Y.Z
```

### 2) 업로드만
```bash
cd ios
fastlane ios release app_version:X.Y.Z
```

### 3) 업로드 + 심사 제출
```bash
cd ios
fastlane ios release_submit app_version:X.Y.Z
```

## preflight 검증 항목
- `pubspec.yaml` 버전 형식(`X.Y.Z+N`) 및 `app_version` 일치 여부
- `ios/Runner/Info.plist` lint
- 필수 privacy key 존재 여부
- `CFBundleVersion == $(FLUTTER_BUILD_NUMBER)` 바인딩 여부
- App Store Connect 최신 빌드보다 `+N` 값이 큰지 확인

## 운영 메모
- `release` 기본값은 metadata 업로드 생략(`skip_metadata: true`)입니다.
- 심사 제출 중 `A review submission is already in progress`는 중복 제출 상태이므로 실패가 아닌 진행 중 상태로 처리됩니다.
- 원격 빌드번호 확인이 어려운 환경에서는 아래처럼 실행 가능합니다.
```bash
fastlane ios preflight app_version:X.Y.Z skip_remote_build_check:true
```
