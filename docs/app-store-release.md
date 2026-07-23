# App Store 배포 자동화

TestFlight 업로드(`beta`)와 별개로, App Store 심사 제출·출시까지 자동화한 파이프라인이다.

| 대상 | lane | 워크플로 |
| --- | --- | --- |
| TestFlight | `fastlane beta` | `.github/workflows/testflight-deploy.yml` |
| App Store | `fastlane release version:1.0.0` | `.github/workflows/appstore-release.yml` |

## 배포 절차

### 1. 메타데이터 갱신

`fastlane/metadata/` 아래 텍스트 파일이 원본이다. App Store Connect 웹에서 수정하지 말고 이 파일들을 고쳐 커밋한다(배포 시 덮어쓰기된다).

```
fastlane/metadata/
├── copyright.txt              # 저작권 표기
├── primary_category.txt       # 기본 카테고리
├── secondary_category.txt     # 보조 카테고리
├── ko/
│   ├── name.txt               # 앱 이름 (30자)
│   ├── subtitle.txt           # 부제 (30자)
│   ├── description.txt        # 설명 (4000자)
│   ├── keywords.txt           # 키워드, 쉼표 구분 (100자)
│   ├── promotional_text.txt   # 홍보 텍스트 (170자, 심사 없이 수정 가능)
│   ├── release_notes.txt      # 이번 버전 변경사항 (4000자)
│   ├── support_url.txt
│   └── privacy_url.txt
└── review_information/
    └── notes.txt              # 심사 담당자용 기능 확인 안내
```

> **심사 담당자 연락처(이름·전화번호·이메일)는 저장소에 두지 않는다.** 개인정보이므로 파일 대신 환경변수로만 다룬다. 로컬은 `fastlane/.env`(gitignore 대상), CI는 GitHub Secrets에서 주입한다.
>
> ```sh
> # fastlane/.env 에 추가
> APP_REVIEW_FIRST_NAME=길동
> APP_REVIEW_LAST_NAME=홍
> APP_REVIEW_PHONE_NUMBER=+82 10-1234-5678
> APP_REVIEW_EMAIL=contact@example.com
> ```

스크린샷은 `fastlane/screenshots/ko/` 에 둔다. 파일명 순서대로 App Store에 정렬되므로 `bangawo_01_`, `bangawo_02_` 처럼 번호를 붙인다.

> 스크린샷은 카피가 얹힌 마케팅 이미지라 재생성이 불가능하므로 `.gitignore` 예외로 저장소에 추적한다. CI 러너는 체크아웃한 파일을 그대로 업로드한다.

### 2. 사전 검증

```sh
bundle exec fastlane verify_metadata
```

필수 파일 누락, `TODO_` 자리표시자, 글자 수 초과, 스크린샷 부재, 심사 연락처 환경변수 누락을 잡는다. 빌드는 30분 이상 걸리므로 반드시 먼저 통과시킨다.

### 3. 배포 실행

**태그 방식(권장)**

```sh
git tag v1.0.0
git push origin v1.0.0
```

**수동 방식**

GitHub Actions → `App Store Release` → `Run workflow` → 버전 입력. 이때 변경사항을 함께 입력하면 이번 배포에 한해 `release_notes.txt` 를 덮어쓴다(커밋되지는 않는다).

### 4. 워크플로 동작

1. **validate** (ubuntu) — 버전 형식과 메타데이터를 검증한다. 여기서 실패하면 macOS 러너를 쓰지 않는다.
2. **release** (macos-15) — match 인증서 설치 → `MARKETING_VERSION` 을 요청 버전으로 갱신 → TestFlight 최신 빌드 넘버 +1 부여 → 아카이브 → 메타데이터·스크린샷·IPA 업로드 → 심사 제출.

심사 승인 시 **자동으로 출시된다**(`automatic_release: true`). 수동 출시로 바꾸려면 `Fastfile` 의 해당 값을 `false` 로 둔다.

## 주의 사항

- 버전은 `v1.0.0` 형식만 허용한다. 태그명에서 `v` 를 뗀 값이 `MARKETING_VERSION` 이 된다.
- 이미 심사 대기 중인 빌드가 있으면 `reject_if_possible: true` 설정에 따라 기존 제출을 반려하고 새로 올린다.
- 수출 규정·IDFA 답변은 `submission_information` 에 하드코딩돼 있다. 광고 SDK를 도입하면 `add_id_info_uses_idfa` 를 갱신해야 한다.
- 앱 이름(`ko/name.txt`)은 App Store 전체에서 고유해야 한다. 최초 등록명과 다르면 업로드가 거절된다.
- 실패 시 `fastlane-logs-{버전}` 아티팩트에 gym 로그가 남는다(14일 보관).

## 필요한 Secrets

TestFlight 워크플로와 동일한 값에 더해, 심사 연락처 4개를 추가로 등록해야 한다.

| Secret | 용도 |
| --- | --- |
| `APP_IDENTIFIER`, `APPLE_ID`, `TEAM_ID` | Appfile |
| `MATCH_PASSWORD`, `MATCH_KEYCHAIN_PASSWORD` | 인증서 복호화·키체인 |
| `CONFIG_PRIVATE_REPO_TOKEN` | 인증서 repo·비공개 xcconfig 접근 |
| `APP_STORE_CONNECT_API_KEY_ID` / `_ISSUER_ID` / `_API_KEY_CONTENT` | App Store Connect API (키는 base64) |
| `APP_REVIEW_FIRST_NAME` / `_LAST_NAME` / `_PHONE_NUMBER` / `_EMAIL` | **신규** — App Review 담당자 연락처 |
