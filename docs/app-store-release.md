# App Store 배포 자동화

TestFlight 업로드(`beta`)와 별개로, App Store 심사 제출·출시까지 자동화한 파이프라인이다.

| 대상 | lane | 워크플로 |
| --- | --- | --- |
| TestFlight | `fastlane beta` | `.github/workflows/testflight-deploy.yml` |
| 태그·릴리즈 노트 | — | `.github/workflows/release-tag.yml` |
| App Store | `fastlane release version:1.0.0` | `.github/workflows/appstore-release.yml` |

> **`release` 는 새로 아카이브하지 않는다.** TestFlight 에서 검증 끝난 RC 빌드를 그대로 심사에 올린다. 즉 출시하려는 버전의 빌드가 먼저 `beta` 로 TestFlight 에 올라가 있어야 하며, 없으면 release 는 즉시 실패한다.
>
> App Store Connect 는 빌드의 마케팅 버전(`CFBundleShortVersionString`)과 같은 App Store 버전에만 그 빌드를 붙일 수 있고 빌드 버전은 빌드 시점에 고정된다. 따라서 **마케팅 버전은 RC 빌드를 만들기 전에 정해져야 한다.** 현재 마케팅 버전 소스는 `Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/Extension+String.swift` 의 `appVersion(version:)` 기본값(`1.0.0`)이므로, 다음 버전을 출시하려면 이 값을 올려 `tuist generate` 후 커밋하고 `beta` 로 RC 를 올린 뒤 같은 버전으로 release 한다.

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

**Release Tag 워크플로(권장)**

GitHub Actions → `Release Tag` → `Run workflow` → 배포할 브랜치(보통 `main`) 선택 → 버전 입력(예: `1.0.1`). 실행하면:

1. 직전 태그 이후 커밋을 커밋 컨벤션 헤더(`[FEAT]`, `[FIX]`, …)별로 묶어 릴리즈 노트를 자동 생성한다(`.github/scripts/generate-release-notes.sh`).
2. `v{version}` 태그와 GitHub Release 를 만든다.
3. 태그 push 가 `App Store Release` 워크플로를 이어서 트리거한다.

> GitHub Release 노트는 개발자용 변경 이력이다. **App Store 심사에 노출되는 `release_notes.txt` 는 자동 생성 대상이 아니므로**, 사용자용 문구는 2단계 이전에 직접 갱신한다.
>
> ⚠️ 태그를 기본 `GITHUB_TOKEN` 으로 push 하면 downstream 워크플로가 트리거되지 않는다(GitHub 정책). 그래서 이 워크플로는 `RELEASE_PAT`(contents:write PAT)로 태그를 만든다. 이 Secret 이 없으면 태그·Release 는 생기지만 App Store Release 가 자동 실행되지 않는다.

**직접 태그 방식**

```sh
git tag v1.0.0
git push origin v1.0.0
```

로컬에서 태그를 직접 밀면 GitHub Release·자동 릴리즈 노트 없이 App Store Release 만 트리거된다.

**App Store Release 수동 실행**

GitHub Actions → `App Store Release` → `Run workflow` → 버전 입력. 이때 변경사항을 함께 입력하면 이번 배포에 한해 `release_notes.txt` 를 덮어쓴다(커밋되지는 않는다).

### 4. 워크플로 동작

1. **validate** (ubuntu) — 버전 형식과 메타데이터를 검증한다. 여기서 실패하면 다음 잡을 실행하지 않는다.
2. **release** (ubuntu) — 아카이브를 새로 만들지 않는다. 요청 버전에 해당하는 TestFlight 최신 빌드를 조회 → (없으면 실패) → 그 빌드를 선택해 메타데이터·스크린샷과 함께 심사 제출한다. 서명·Xcode·Tuist 가 필요 없어 ubuntu 에서 돈다.

심사 승인 시 **자동으로 출시된다**(`automatic_release: true`). 수동 출시로 바꾸려면 `Fastfile` 의 해당 값을 `false` 로 둔다.

## 주의 사항

- 버전은 `v1.0.0` 형식만 허용한다. 태그명에서 `v` 를 뗀 값이 **제출할 TestFlight 빌드를 고르는 키**가 된다(버전을 코드에 주입하지 않으므로, 그 버전의 빌드가 TestFlight 에 미리 올라가 있어야 한다).
- 이미 심사 대기 중인 빌드가 있으면 `reject_if_possible: true` 설정에 따라 기존 제출을 반려하고 새로 올린다.
- 수출 규정·IDFA 답변은 `submission_information` 에 하드코딩돼 있다. 광고 SDK를 도입하면 `add_id_info_uses_idfa` 를 갱신해야 한다.
- 앱 이름(`ko/name.txt`)은 App Store 전체에서 고유해야 한다. 최초 등록명과 다르면 업로드가 거절된다.
- 실패 시 `fastlane-logs-{버전}` 아티팩트에 `report.xml` 이 남는다(14일 보관).

## 필요한 Secrets

TestFlight 워크플로와 동일한 값에 더해, 심사 연락처 4개를 추가로 등록해야 한다.

| Secret | 용도 |
| --- | --- |
| `APP_IDENTIFIER`, `APPLE_ID`, `TEAM_ID` | Appfile |
| `MATCH_PASSWORD`, `MATCH_KEYCHAIN_PASSWORD` | 인증서 복호화·키체인 (TestFlight 전용, release 잡에는 불필요) |
| `CONFIG_PRIVATE_REPO_TOKEN` | 인증서 repo·비공개 xcconfig 접근 (TestFlight 전용, release 잡에는 불필요) |
| `APP_STORE_CONNECT_API_KEY_ID` / `_ISSUER_ID` / `_API_KEY_CONTENT` | App Store Connect API (키는 base64) |
| `APP_REVIEW_FIRST_NAME` / `_LAST_NAME` / `_PHONE_NUMBER` / `_EMAIL` | App Review 담당자 연락처 |
| `RELEASE_PAT` | `Release Tag` 워크플로 전용. 태그 push 가 App Store Release 를 트리거하도록 하는 PAT(contents:write) |

> **`RELEASE_PAT` 발급**: GitHub → Settings → Developer settings → Fine-grained tokens → 이 저장소 대상, `Contents: Read and write` 권한으로 발급해 저장소 Secret 에 등록한다. 기본 `GITHUB_TOKEN` 이 만든 태그는 다른 워크플로를 트리거하지 못하기 때문에 필요하다.

> release 잡은 아카이브·서명을 하지 않으므로 `MATCH_*` 와 `CONFIG_PRIVATE_REPO_TOKEN` 을 쓰지 않는다. 다만 이 값들은 TestFlight 워크플로에 여전히 필요하니 삭제하지 않는다.
