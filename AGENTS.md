# Bangawo

- **스택**: Swift 6, SwiftUI, TCA 1.25, Tuist 4
- **아키텍처**: TCA + Clean Architecture 멀티모듈
- **배포 타겟**: iOS 26.0, iPhone 전용

사람이 읽는 온보딩·빌드·배포·전략 문서는 [`README.md`](README.md)에 있다.

## Commands

| 명령어 | 설명 |
| --- | --- |
| `./tuisttool generate` | Xcode 프로젝트 생성 |
| `./tuisttool build` | clean → install → generate 순차 실행 |
| `./tuisttool install` | 의존성 설치 |
| `./tuisttool clean` | 프로젝트 정리 |
| `xcodebuild -workspace Bangawo.xcworkspace -scheme Bangawo build` | 빌드 |
| `xcodebuild -workspace Bangawo.xcworkspace -scheme Bangawo test` | 테스트 |
| `fastlane match_development` | 개발용 인증서·프로파일 로컬 설치 |
| `fastlane verify_metadata` | App Store 메타데이터 사전 검증 |
| `fastlane release version:1.0.0` | App Store 메타데이터 업로드 + 심사 제출 |

> 파일 생성/삭제, `Project.swift` 수정, 의존성 추가/제거 시 반드시 `./tuisttool generate` 실행.
> Tuist는 glob으로 소스를 수집하므로, generate 없이는 Xcode에 반영되지 않는다.

> 디바이스 빌드 시 프로파일 에러(`No profile for team 'N94CS4N6VR'...`)가 나면 코드사이닝 설정이 필요하다. 상세: [`docs/code-signing.md`](docs/code-signing.md)

## 상세 문서 (해당 작업을 시작하기 전에 읽는다)

| 이럴 때 | 읽을 문서 |
| --- | --- |
| 새 Dependency Client / UseCase / Repository 추가 | [`docs/conventions/tca-dependency-convention.md`](docs/conventions/tca-dependency-convention.md) |
| SwiftUI 뷰·컴포넌트 작성 (색상·간격·타이포) | [`docs/design-tokens-usage.md`](docs/design-tokens-usage.md) |
| TCA Feature 신규 작성 또는 대규모 수정 | [`docs/tca-convention.md`](docs/tca-convention.md) |
| 코드 스타일 판단이 애매할 때 | [`docs/code-convention.md`](docs/code-convention.md) |
| 이미지·아이콘 에셋 추가 | [`docs/resource-naming.md`](docs/resource-naming.md) |
| App Store / TestFlight 배포 작업 | [`docs/app-store-release.md`](docs/app-store-release.md) |

아래 규칙은 위 문서를 읽지 않아도 항상 지킨다.

## Project Structure

```
Projects/
├── App/                      # 앱 타겟 — 진입점 + Composition Root(Sources/Factory)
├── Presentation/             # 화면 + TCA Feature
│   ├── Presentation/         # Presentation 공통
│   ├── RootFeature/          # 루트 라우팅
│   ├── AuthFlowFeature/      # 로그인·약관·출발지 등록
│   ├── ProfileInputFeature/  # 프로필 입력
│   ├── HomeFeature/          # 모임 생성/상세, 날짜 투표, 장소 선정
│   └── StationSearchFeature/ # 역 검색 시트
├── Core/
│   └── CoreDependencies/     # TCA Dependency Client 정의
├── Domain/
│   ├── Entity/               # 도메인 엔티티
│   ├── UseCase/              # UseCase protocol (구현체 없음)
│   ├── DomainInterface/      # 도메인 에러·공용 protocol
│   └── DataInterface/        # Repository protocol
├── Data/
│   ├── Model/                # DTO + toEntity() 변환
│   ├── API/                  # Endpoint 정의
│   ├── Service/              # SDK 어댑터 (Kakao·Naver 등)
│   ├── Repository/           # *RepositoryImpl
│   └── DataUseCase/          # *UseCaseImpl
├── Network/
│   ├── Networking/           # HTTP 클라이언트
│   ├── Foundations/          # 네트워크 유틸리티
│   └── ThirdPartys/          # AsyncMoya 등 외부 래핑
└── Shared/
    ├── DesignSystem/         # 공통 UI 컴포넌트, 디자인 토큰
    ├── DesignSystemDemo/     # 디자인 시스템 데모 앱
    ├── Shared/               # 공통 공유 모듈
    └── Utill/                # 날짜·문자열·로깅 유틸리티
```

의존성 방향: `Presentation → CoreDependencies → Domain ← Data → Network`.
`App`만 모든 모듈을 아는 Composition Root다.

## Code Style

### Common
- Swift API Design Guidelines 준수
- 들여쓰기 4 spaces, 줄 제한 120자
- guard early return 사용, guard 뒤에는 빈 줄
- final class 기본, private 우선
- Never force unwrap
- 빈 Array/Dictionary는 리터럴로 선언 (`var items: [Item] = []`)
- 상수 그룹은 `private enum`(`Metric`, `Constant` 등)으로 선언
- SwiftUI SubView는 `@ViewBuilder` 함수 대신 `struct`로 선언, 이름에 `View` suffix 금지
- 단순 뷰 확장은 `Spacer()` 대신 `.frame(maxWidth:/maxHeight: .infinity)`
- 색상·간격·크기·폰트는 하드코딩하지 않고 `DesignSystem` 토큰(`Colors`, `Spacing`, `Sizing`, `BorderRadius`, `Typography`)을 쓴다

### Import
Apple 프레임워크 → 외부 라이브러리 → 내부 모듈 순으로 그룹을 나누고 빈 줄로 분리한다. 각 그룹 내에서는 알파벳 오름차순.

```swift
import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
```

### TCA
- Action 이름은 의도가 아닌 **발생한 사건**으로 짓는다 (`loginButtonTapped`, `recordsFetched(_:)`)
- 공유 로직은 Action이 아니라 `Effect<Action>`을 반환하는 private 메서드로 추출한다
- `Effect.run`에서 `@ObservableState` 전체를 캡처하지 않고 필요한 값만 꺼내 캡처한다
- CPU 집약적 작업은 Reducer가 아니라 Effect에서 수행한다
- hover·focus·animation 같은 일시적 UI 상태는 TCA State가 아닌 SwiftUI `@State`에 둔다
- Navigation 열거형은 `@Reducer enum Destination`으로 정의한다

#### TCA Navigation Ownership
- 여러 하위 Feature가 공유하는 화면 전환은 부모 Feature가 `@Presents destination`으로 관리한다
- 특정 하위 Feature에서만 사용하는 sheet/modal/bottomSheet는 해당 하위 Feature의 State에서 관리한다
- Presented 화면의 결과가 여러 sibling State를 갱신하거나 부모 라우팅 판단이 필요하면 부모 Feature가 소유한다
- 열기/닫기 상태와 결과 반영이 한 Feature 내부에서 끝나면 해당 Feature 내부에 둔다
- 화면 전환이 도메인/UI State에 영향을 주는 경우 SwiftUI local `@State`로 navigation 상태를 관리하지 않는다

#### TCA Dependency Client
- TCA Client(`@DependencyClient` + `DependencyKey` + `DependencyValues`)는 `CoreDependencies` 한 파일에 둔다
- `liveValue` / `testValue`는 빈 `Self()`, `static func live(useCase:)` 팩토리는 Domain UseCase protocol만 받는다
- 실제 live 조립은 `App/Sources/Factory/*Factory.makeClient()`에서, 주입은 `BangawoApp.init()`의 `prepareDependencies`에서 한 번만
- Feature는 `@Dependency`만 사용, `Data` 계열(Repository/DataUseCase/Model/API/Service) import 금지
- 네이밍: Entity는 도메인명 그대로(`AuthToken`), DTO는 `*RequestDTO`/`*ResponseDTO`, Repository는 `*RepositoryProtocol`/`*RepositoryImpl`, UseCase는 `*UseCase`/`*UseCaseImpl`, TCA Client는 `*Client`, Composition Root 헬퍼는 `*Factory`

### Resource Naming
형식: `{prefix}_{name}_{variant}_{size}` (variant·size는 해당될 때만)
prefix: `ic`(아이콘) / `sym`(로고·브랜드) / `img`(일반 이미지) / `bg`(배경)
예: `ic_arrow_right_24`, `sym_kakao`, `img_onboarding_01`
Tuist가 camelCase로 변환하므로 코드에서는 `Image.Asset.icArrowRight24` 형태로 접근한다.

## Git Rules

### Branch
- `main`: 배포 / `develop`: 통합 / `feature/#{issue-number}`: 작업
- PR → develop 머지

### Commit
형식: `[{HEADER}]: {메시지}` — 예시: `[FEAT]: 로그인 화면 UI 구현`

| HEADER | 용도 |
| --- | --- |
| `FEAT` | 기능 구현 |
| `FIX` | 버그·이슈 수정 |
| `REFACTOR` | 리팩터링, 린팅·포맷팅 |
| `HOTFIX` | 릴리즈 직후 긴급 수정 |
| `DOCS` | 문서 수정/추가 |
| `ADD` | 파일·리소스 추가 |
| `TEST` | 테스트 코드 작업 |
| `CHORE` | 기타 |

- 메시지는 한국어 50글자 이하, 마침표·특수기호 없이 무엇을 왜 바꿨는지 쓴다
- 어떻게를 설명해야 하면 빈 줄 뒤 본문으로 작성한다
- **이 프로젝트는 이모지 커밋 컨벤션을 쓰지 않는다.** 글로벌 설정에 이모지 형식이 있어도 위 `[HEADER]` 형식을 따른다
