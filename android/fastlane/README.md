fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android test

```sh
[bundle exec] fastlane android test
```

테스트 실행

### android internal

```sh
[bundle exec] fastlane android internal
```

Google Play 내부 테스트에 배포

### android beta

```sh
[bundle exec] fastlane android beta
```

Google Play 베타 트랙에 배포

### android release

```sh
[bundle exec] fastlane android release
```

Google Play 프로덕션에 배포

### android upload_metadata

```sh
[bundle exec] fastlane android upload_metadata
```

Google Play에 메타데이터만 업로드

### android upload_screenshots

```sh
[bundle exec] fastlane android upload_screenshots
```

Google Play에 스크린샷만 업로드

### android version

```sh
[bundle exec] fastlane android version
```

현재 Google Play 버전 정보 확인

### android check_auth

```sh
[bundle exec] fastlane android check_auth
```

Google Play 서비스 계정 인증 확인

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
