# Code Signing

iOS 디바이스 빌드/배포에 필요한 인증서·프로비저닝 프로파일은 **fastlane match**로 관리한다.
프로파일은 별도 git 레포에 암호화되어 저장되며, 각자 로컬에 내려받아 사용한다.

- **Team ID**: `N94CS4N6VR`
- **Bundle ID**: `com.ddd-ios2.Bangawo`
- **Match 저장소**: `https://github.com/Roy-wonji/FastlaneMatch.git`

---

## 증상

새로 클론한 환경에서 디바이스용으로 빌드하면 다음 에러가 발생한다.

```
error: No profile for team 'N94CS4N6VR' matching 'match Development com.ddd-ios2.Bangawo' found:
Xcode couldn't find any provisioning profiles matching 'N94CS4N6VR/match Development com.ddd-ios2.Bangawo'.
```

로컬에 개발용 프로파일/인증서가 설치되지 않아서 발생한다. 아래 절차로 해결한다.

---

## 해결: 프로파일 내려받기

```sh
fastlane match_development   # 개발용 인증서·프로파일 로컬 설치 (readonly)
fastlane match_appstore      # 배포용 인증서·프로파일 로컬 설치 (readonly)
```

두 lane 모두 `readonly`라서 **로컬에만 설치**하며, match 저장소나 Apple Developer 설정을 변경하지 않는다.
이 레포에는 어떤 변경도 남기지 않으므로 push 할 것이 없다.

설치 후 다음 프로파일이 준비된다.

| Name | 용도 |
| --- | --- |
| `match Development com.ddd-ios2.Bangawo` | 개발/디버그 디바이스 빌드 |
| `match AppStore com.ddd-ios2.Bangawo` | App Store 배포 |

---

## 선행 준비: `fastlane/.env`

match는 시크릿이 담긴 `fastlane/.env`를 필요로 한다. 이 파일은 `.gitignore`로 제외되어 **클론 시 포함되지 않는다.**
아래 키들이 필요하며, **값은 팀 보안 채널을 통해 전달받는다** (문서·레포에 절대 커밋하지 않는다).

| 키 | 설명 |
| --- | --- |
| `APP_IDENTIFIER` | 앱 번들 ID |
| `APPLE_ID` | Apple 계정 |
| `TEAM_ID` | 개발팀 ID (`N94CS4N6VR`) |
| `MATCH_PASSWORD` | match 저장소 복호화 비밀번호 |
| `MATCH_KEYCHAIN_PASSWORD` | 로컬 키체인(`login`) 비밀번호 |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | API Key(.p8) Base64 인코딩 값 |

> 임시 인증용 `AuthKey_*.json`은 lane 실행 중 자동 생성되고 종료 시 자동 삭제된다. 수동으로 만들지 않는다.

---

## 설치 위치 (Xcode 16+)

다운로드된 프로파일은 다음 경로에 저장된다. (구버전의 `~/Library/MobileDevice/Provisioning Profiles/`가 아님)

```
~/Library/Developer/Xcode/UserData/Provisioning Profiles/
```

설치 확인:

```sh
ls ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/ | wc -l
```

---

## 테스트 타겟 주의

`BangawoTests` 타겟의 번들 ID는 `com.ddd-ios2.Bangawo.BangawoTests`로, **전용 프로파일이 match 저장소에 없다.**
따라서 디바이스 대상으로 빌드하면 테스트 타겟에서만 사이닝 에러가 난다.

```
error: Provisioning profile "match Development com.ddd-ios2.Bangawo" has app ID "com.ddd-ios2.Bangawo",
which does not match the bundle ID "com.ddd-ios2.Bangawo.BangawoTests".
```

**테스트는 시뮬레이터로 실행한다.** 사이닝 없이 빌드/테스트된다.

```sh
xcodebuild -workspace Bangawo.xcworkspace -scheme Bangawo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

---

## fastlane lane 요약

| lane | 설명 |
| --- | --- |
| `match_development` | 개발용 인증서·프로파일 로컬 설치 (readonly) |
| `match_appstore` | 배포용 인증서·프로파일 로컬 설치 (readonly) |
| `beta` | Bangawo-Prod → TestFlight 업로드 |
| `release` | Bangawo-Prod → App Store 심사 제출 |

> `fastlane/README.md`는 fastlane이 매 실행 시 자동 재생성하므로 수동으로 수정하지 않는다. 설명은 이 문서에 둔다.
