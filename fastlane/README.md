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

### ios match_development

```sh
[bundle exec] fastlane ios match_development
```

개발용 인증서 로컬 설치 (readonly)

### ios match_appstore

```sh
[bundle exec] fastlane ios match_appstore
```

배포용 인증서 로컬 설치 (readonly)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Bangawo-Prod → TestFlight 업로드

### ios release

```sh
[bundle exec] fastlane ios release
```

TestFlight 검증 빌드를 App Store 심사 제출 + 자동 출시

### ios dedupe_screenshots

```sh
[bundle exec] fastlane ios dedupe_screenshots
```

App Store Connect 의 중복 스크린샷 제거 (파일명당 1장만 남김, 재업로드 안 함)

### ios list_screenshots

```sh
[bundle exec] fastlane ios list_screenshots
```

App Store Connect 에 올라간 스크린샷 전체 목록 출력 (읽기 전용 진단)

### ios verify_metadata

```sh
[bundle exec] fastlane ios verify_metadata
```

메타데이터 미기입/누락 검증 (배포 전 사전 점검)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
