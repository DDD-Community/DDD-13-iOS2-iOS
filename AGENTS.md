# Bangawo

- **스택**: Swift 6, SwiftUI, TCA 1.25, Tuist 4
- **아키텍처**: TCA + Clean Architecture 멀티모듈
- **배포 타겟**: iOS 26.0, iPhone 전용

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

> 파일 생성/삭제, `Project.swift` 수정, 의존성 추가/제거 시 반드시 `./tuisttool generate` 실행.
> Tuist는 glob으로 소스를 수집하므로, generate 없이는 Xcode에 반영되지 않는다.

> 디바이스 빌드 시 프로파일 에러(`No profile for team 'N94CS4N6VR'...`)가 나면 코드사이닝 설정이 필요하다. 상세: [`docs/code-signing.md`](docs/code-signing.md)

## Project Structure

```
Projects/
├── App/                  # 앱 타겟 (진입점, DI 조립)
├── Presentation/         # 화면 + ViewModel (TCA Feature)
├── Domain/
│   ├── Entity/           # 도메인 엔티티 + Protocol
│   ├── UseCase/          # 비즈니스 로직 구현
│   ├── DomainInterface/  # Domain 계층 인터페이스
│   └── DataInterface/    # Data 계층 인터페이스
├── Data/
│   ├── Model/            # DTO, API Response → Entity 변환
│   ├── Repository/       # Repository 구현체
│   ├── API/              # REST API Endpoint
│   └── Service/          # 데이터 처리 서비스
├── Network/
│   ├── Networking/       # HTTP 클라이언트 설정
│   ├── Foundations/      # 네트워크 기반 유틸리티
│   └── ThirdPartys/     # AsyncMoya, WeaveDI 등
└── Shared/
    ├── DesignSystem/     # 공통 UI 컴포넌트, 폰트, 색상
    ├── Shared/           # 공통 공유 모듈
    └── Utill/            # 날짜, 문자열, 로깅 유틸리티
```

의존성 방향: `Presentation → Domain ← Data`, `Network`는 `Data`에서만 참조.

## Code Style

### Common
- Swift API Design Guidelines 준수
- 들여쓰기 4 spaces, 줄 제한 120자
- guard early return 사용
- final class 기본, private 우선
- Never force unwrap

### SwiftUI / Swift
상세 컨벤션: `docs/code-convention.md`

### TCA
상세 컨벤션: `docs/tca-convention.md`

## Resource Naming
상세 규칙: `docs/resource-naming.md`

---

#### TCA Dependency Client
- TCA Client(`@DependencyClient` + `DependencyKey` + `DependencyValues`)는 `CoreDependencies` 한 파일에 둔다
- `liveValue` / `testValue`는 빈 `Self()`, `static func live(useCase:)` 팩토리는 Domain UseCase protocol만 받는다
- 실제 live 조립은 `App/Sources/Factory/*Factory.makeClient()`에서, 주입은 `BangawoApp.init()`의 `prepareDependencies`에서 한 번만
- Feature는 `@Dependency`만 사용, `Data` 계열(Repository/DataUseCase/Model/API/Service) import 금지
- 네이밍: Entity는 도메인명 그대로(`AuthToken`), DTO는 `*RequestDTO`/`*ResponseDTO`, Repository는 `*RepositoryProtocol`/`*RepositoryImpl`, UseCase는 `*UseCase`/`*UseCaseImpl`, TCA Client는 `*Client`, Composition Root 헬퍼는 `*Factory`
- 상세 예시·의존성 표·금지 사항은 [`docs/conventions/tca-dependency-convention.md`](docs/conventions/tca-dependency-convention.md) 참고

## Git Rules

### Branch
- `main`: 배포 / `develop`: 통합 / `feature/#{issue-number}`: 작업
- PR → develop 머지

### Commit
상세 컨벤션: `docs/commit-convention.md`

형식: `[{Header}]: {Message}` — 예시: `[FEAT]: 로그인 화면 UI 구현`
