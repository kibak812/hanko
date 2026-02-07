fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios preflight

```sh
[bundle exec] fastlane ios preflight
```

iOS 배포 전 점검 (Info.plist, 버전/빌드, App Store Connect 빌드 번호)

### ios test

```sh
[bundle exec] fastlane ios test
```

테스트 실행

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

앱 스크린샷 캡처

### ios frames

```sh
[bundle exec] fastlane ios frames
```

스크린샷에 디바이스 프레임 적용

### ios screenshots_with_frames

```sh
[bundle exec] fastlane ios screenshots_with_frames
```

스크린샷 캡처 + 프레임 적용

### ios beta

```sh
[bundle exec] fastlane ios beta
```

TestFlight에 베타 버전 배포

### ios release

```sh
[bundle exec] fastlane ios release
```

App Store에 프로덕션 버전 배포 (기본: metadata 업로드 생략)

### ios release_submit

```sh
[bundle exec] fastlane ios release_submit
```

업로드 + 심사 제출까지 한 번에 실행

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

App Store에 스크린샷만 업로드

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

App Store에 메타데이터만 업로드

### ios submit_review

```sh
[bundle exec] fastlane ios submit_review
```

App Store 심사 제출

### ios sync_certs

```sh
[bundle exec] fastlane ios sync_certs
```

인증서 및 프로비저닝 프로파일 동기화 (match)

### ios create_certs

```sh
[bundle exec] fastlane ios create_certs
```

새 인증서 생성 (주의: 기존 인증서 무효화될 수 있음)

### ios version

```sh
[bundle exec] fastlane ios version
```

버전 번호 확인

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

버전 번호 증가 (major.minor.patch)

### ios check_api_key

```sh
[bundle exec] fastlane ios check_api_key
```

App Store Connect API 키 설정 확인

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
