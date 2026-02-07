# iOS Release Checklist

배포 커맨드 실행 전 1분 점검표입니다.

## 1. 버전/빌드
- `pubspec.yaml`의 `version`이 이번 릴리즈 목표와 일치하는지 확인
- 같은 `X.Y.Z` 버전 재업로드 시 `+N` 빌드 번호를 반드시 증가

## 2. Privacy 키
- `ios/Runner/Info.plist`에 아래 키가 모두 존재하는지 확인
- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`

## 3. 인증/권한
- App Store Connect API 환경변수 확인
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_PATH`

## 4. 권장 lane 순서
- 사전 점검: `fastlane ios preflight app_version:X.Y.Z`
- 업로드만: `fastlane ios release app_version:X.Y.Z`
- 업로드+심사제출: `fastlane ios release_submit app_version:X.Y.Z`

## 5. 처리 지연 대응
- `submit_review` 단계에서 `A review submission is already in progress`가 나오면
  이미 심사 제출이 진행 중인 상태로 간주
