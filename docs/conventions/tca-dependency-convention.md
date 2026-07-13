# TCA Dependency 컨벤션

본 프로젝트의 TCA 의존성(Dependency Client) 작성 규칙. 신규 Feature/Client 를 추가할 때 본 문서를 따른다.

기준 reference 구현:
- `Projects/Core/CoreDependencies/Sources/SearchStationsClient.swift`
- `Projects/App/Sources/Factory/SearchStationsFactory.swift`
- `Projects/App/Sources/Application/BangawoApp.swift`

## 1. 목적

TCA 에서 의존성을 **struct-based client 단일 파일 패턴**으로 통일한다.

목표:
- Feature 가 구현 세부사항을 모르도록 한다
- 테스트/프리뷰에서 의존성 override 를 쉽게 한다
- Domain UseCase 와 TCA Dependency Client 의 역할을 분리한다
- 실제 구현체 조립은 App 의 Composition Root 에서만 수행한다
- Presentation 이 Data 계층 구현체에 직접/간접 의존하지 않도록 한다

## 2. 모듈 구조

```text
Projects/
├── App/
│   └── Sources/
│       ├── Application/      # BangawoApp (prepareDependencies 진입점)
│       └── Factory/          # SearchStationsFactory 같은 Composition Root
├── Core/
│   └── CoreDependencies/     # TCA struct-based Client + DependencyKey + DependencyValues
├── Domain/
│   ├── Entity/               # 도메인 모델 (Station 등)
│   ├── UseCase/              # UseCase protocol
│   ├── DomainInterface/      # 도메인 에러/공통 인터페이스
│   └── DataInterface/        # Repository protocol
├── Data/
│   ├── Model/                # DTO + toEntity()
│   ├── API/                  # Endpoint
│   ├── Service/              # SDK adapter (Kakao 등)
│   ├── Repository/           # *RepositoryImpl
│   └── DataUseCase/          # *UseCaseImpl
├── Network/
│   ├── Networking/           # NetworkManager
│   ├── Foundations/
│   └── ThirdPartys/
├── Presentation/
│   ├── Presentation/         # 공통 Presentation 유틸
│   └── {Feature}Feature/     # 기능별 Feature + View
└── Shared/{DesignSystem, Shared, Utill}
```

의존 방향: `Presentation → CoreDependencies → Domain ← Data`. `Network` 는 `Data` 에서만 참조한다. `App` 만 Composition Root 로서 모든 모듈을 알 수 있다.

## 3. 레이어별 책임

### Presentation / Feature
- `@Dependency` 로만 외부 의존성을 사용한다
- SDK/API 직접 호출 금지
- Repository/UseCase/Service 구현체 직접 생성 금지
- `Data` 계열 모듈 import 금지 (`Repository`, `DataUseCase`, `Model`, `API`, `Service`)
- View 는 사용자 이벤트를 Feature Action 으로 전달

### CoreDependencies
- TCA struct-based client 정의 (`@DependencyClient`)
- `DependencyKey` 채택 (`liveValue`/`testValue` 는 빈 인스턴스)
- `DependencyValues` 확장으로 키 노출
- Domain UseCase protocol 을 받는 `static func live(useCase:)` 팩토리 제공
- `Data` 계열 구현체 import 금지 (Domain UseCase protocol 만 사용)
- Assembly/Factory 호출 금지 (실제 조립은 `App` 의 책임)

### Domain
- `Entity`: 외부 SDK/네트워크 타입 금지, DTO 노출 금지
- `UseCase`: protocol 만 정의, 비즈니스 흐름 추상화
- `DomainInterface`: 에러 타입, 도메인 공용 protocol
- `DataInterface`: Repository protocol. Entity 만 반환, DTO 반환 금지

### Data
- 실제 구현 담당
- `Model`: DTO + Entity 변환(`toEntity`)
- `API`: Endpoint 정의
- `Service`: SDK 직접 호출(Kakao 로그인 등). SDK 응답을 도메인 모델로 변환
- `Repository`: `*RepositoryImpl` (DataInterface 구현)
- `DataUseCase`: `*UseCaseImpl` (Domain UseCase 구현, Repository/Service 조합)

### App
- Composition Root
- `Sources/Factory/` 에서 Repository → UseCase → Client 조립
- `Sources/Application/BangawoApp.swift` 의 `prepareDependencies` 에서 live 주입
- 모든 모듈을 import 가능

## 4. 네이밍 컨벤션

| 위치 | 패턴 | 예시 |
| --- | --- | --- |
| `Domain/Entity` | 도메인명 그대로 (suffix 없음) | `AuthToken`, `SocialAuthProvider`, `SocialAuthToken`, `Station` |
| `Data/Model` | 요청/응답: `*RequestDTO` / `*ResponseDTO`, 그 외: `*DTO` | `LoginRequestDTO`, `LoginResponseDTO`, `KakaoLocalSearchResponseDTO` |
| `Domain/DataInterface` | `*RepositoryProtocol` | `AuthRepositoryProtocol`, `LocationSearchRepositoryProtocol` |
| `Data/Repository` | `*RepositoryImpl` | `AuthRepositoryImpl`, `LocationSearchRepositoryImpl` |
| `Domain/UseCase` | `*UseCase` (Protocol suffix 미사용) | `SignInWithSocialUseCase`, `SearchStationsUseCase` |
| `Data/DataUseCase` | `*UseCaseImpl` | `SignInWithSocialUseCaseImpl`, `SearchStationsUseCaseImpl` |
| `Data/Service` | 인터페이스: `*ServiceInterface`, 구현: `*Service` | `KakaoLoginServiceInterface`, `KakaoLoginService` |
| `Data/API` | `*Endpoint` | `KakaoLocalEndpoint`, `AuthEndpoint` |
| `CoreDependencies` | `*Client` | `SearchStationsClient`, `SocialAuthClient` |
| `App/Sources/Factory` | `*Factory` (`enum`, `make*()` 정적 메서드) | `SearchStationsFactory`, `SocialAuthFactory` |

규칙:
- **Entity**: 외부 표현(서버/SDK)을 모르는 순수 도메인 명사 그대로 사용. `*Entity` 같은 접미사 금지
- **DTO**: 항상 `DTO` 접미사. 요청/응답 형태가 명확하면 `Request` / `Response` 와 함께 표시 (`LoginRequestDTO`)
- **Repository**: protocol 은 `Protocol` 접미사로 인터페이스임을 명시, 구현체는 `Impl` 접미사로 1:1 대응
- **UseCase**: protocol 자체가 동작 명사(`SignInWithSocial`)이므로 `Protocol` 접미사를 붙이지 않는다. 구현체만 `Impl` 접미사
- **Service**: SDK 어댑터. SDK 직접 의존 protocol 은 `*ServiceInterface`, 구현은 `*Service`
- **TCA Client**: 항상 `Client` 접미사. Domain UseCase 와 1:N 으로 대응될 수 있다 (한 Client 가 여러 UseCase 를 받아도 됨)
- **Factory**: Composition Root 의 조립 헬퍼는 `enum` + `static func make*() -> *Client` 시그니처

## 5. 파일 예시

### CoreDependencies — `SearchStationsClient.swift`

```swift
import ComposableArchitecture
import Entity
import Foundation
import UseCase

@DependencyClient
public struct SearchStationsClient: Sendable {
    public var searchStations: @Sendable (_ keyword: String) async throws -> [Station]
}

public extension SearchStationsClient {
    static func live(useCase: SearchStationsUseCase) -> Self {
        Self(
            searchStations: { keyword in
                try await useCase.execute(keyword: keyword)
            }
        )
    }
}

extension SearchStationsClient: DependencyKey {
    public static let liveValue: SearchStationsClient = SearchStationsClient()
    public static let testValue: SearchStationsClient = SearchStationsClient()
}

public extension DependencyValues {
    var searchStationsClient: SearchStationsClient {
        get { self[SearchStationsClient.self] }
        set { self[SearchStationsClient.self] = newValue }
    }
}
```

규칙:
- 한 파일에 `@DependencyClient struct` + `static func live(useCase:)` 팩토리 + `DependencyKey` 채택 + `DependencyValues` 확장을 모두 둔다
- `liveValue` / `testValue` 는 인자 없는 빈 `Self()` 로 둔다 (`@DependencyClient` 가 unimplemented 기본값을 자동 생성). 실제 live 주입은 `App` 의 `prepareDependencies` 가 담당
- `static func live(useCase:)` 의 인자는 Domain `UseCase` protocol 이어야 한다 (Repository/Service 직접 받지 않는다)
- import 는 `ComposableArchitecture`, `Entity`, `UseCase` 그리고 필요 시 `DomainInterface` 까지만 허용

### Domain/Entity — `Station.swift`

```swift
import Foundation

public struct Station: Equatable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let addressName: String
    public let roadAddressName: String
    public let x: Double
    public let y: Double

    public init(
        id: String,
        name: String,
        addressName: String,
        roadAddressName: String,
        x: Double,
        y: Double
    ) {
        self.id = id
        self.name = name
        self.addressName = addressName
        self.roadAddressName = roadAddressName
        self.x = x
        self.y = y
    }
}
```

규칙: 외부 SDK/네트워크 타입 의존 금지. `Equatable, Sendable` 기본 채택.

### Domain/UseCase — `SearchStationsUseCase.swift`

```swift
import Entity
import Foundation

public protocol SearchStationsUseCase: Sendable {
    func execute(keyword: String) async throws -> [Station]
}
```

규칙: protocol 만. 구현은 `Data/DataUseCase` 에서.

### Domain/DataInterface — `LocationSearchRepositoryProtocol.swift`

```swift
import Entity
import Foundation

public protocol LocationSearchRepositoryProtocol: Sendable {
    func searchStations(keyword: String) async throws -> [Station]
}
```

규칙: Entity 만 반환. DTO 노출 금지.

### Data/Model — `KakaoLocalSearchResponseDTO.swift`

```swift
import Entity
import Foundation

public struct KakaoLocalSearchResponseDTO: Decodable, Sendable {
    public let documents: [Document]

    public struct Document: Decodable, Sendable {
        public let placeName: String
        public let addressName: String
        public let roadAddressName: String
        public let x: String
        public let y: String

        enum CodingKeys: String, CodingKey {
            case placeName = "place_name"
            case addressName = "address_name"
            case roadAddressName = "road_address_name"
            case x
            case y
        }
    }
}

public extension KakaoLocalSearchResponseDTO.Document {
    func toEntity() throws -> Station {
        guard let xCoordinate = Double(x), let yCoordinate = Double(y) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Kakao Local 좌표 변환 실패")
            )
        }
        return Station(
            id: "\(placeName)|\(x),\(y)",
            name: placeName,
            addressName: addressName,
            roadAddressName: roadAddressName,
            x: xCoordinate,
            y: yCoordinate
        )
    }
}
```

규칙: DTO → Entity 변환은 Model 안의 `toEntity()` 메서드로 한정. 비즈니스 로직 금지(좌표 파싱·서버 형식 매핑까지만).

### Data/Repository — `LocationSearchRepositoryImpl.swift`

```swift
import API
import DataInterface
import Entity
import Foundation
import Model
import Networking

private enum Constant {
    static let subwayCategory = "SW8"
}

public struct LocationSearchRepositoryImpl: LocationSearchRepositoryProtocol {
    public init() {}

    public func searchStations(keyword: String) async throws -> [Station] {
        let response: KakaoLocalSearchResponseDTO = try await NetworkManager.shared.request(
            KakaoLocalEndpoint.searchKeyword(query: keyword, categoryGroupCode: Constant.subwayCategory)
        )
        return try response.documents.map { try $0.toEntity() }
    }
}
```

규칙: `DataInterface` protocol 채택. `NetworkManager` 호출은 Repository 안에서만. DTO 가 외부로 새지 않게 한다.

### Data/DataUseCase — `SearchStationsUseCaseImpl.swift`

```swift
import DataInterface
import Entity
import Foundation
import UseCase

public final class SearchStationsUseCaseImpl: SearchStationsUseCase {
    private let repository: LocationSearchRepositoryProtocol

    public init(repository: LocationSearchRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(keyword: String) async throws -> [Station] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let raw = try await repository.searchStations(keyword: trimmed)
        return StationResultProcessor.process(raw, keyword: trimmed)
    }
}
```

규칙: Repository / Service 를 조합해 Domain UseCase 를 구현. 비즈니스 룰(필터·정렬 등)은 여기에 둔다.

### Data/Service — SDK 어댑터 (가상 예시)

```swift
import DomainInterface
import Entity
import KakaoSDKAuth
import KakaoSDKUser

public protocol KakaoLoginServiceInterface: Sendable {
    @MainActor
    func login() async throws -> SocialAuthToken
}

public final class KakaoLoginService: KakaoLoginServiceInterface {
    public init() {}

    @MainActor
    public func login() async throws -> SocialAuthToken {
        // 실제 Kakao SDK 호출 → SocialAuthToken 으로 변환
    }
}
```

규칙: SDK import 는 Service 안에 격리. SDK 응답을 도메인 모델/공통 모델로 변환해서 외부에 노출.

### App/Factory — `SearchStationsFactory.swift`

```swift
import CoreDependencies
import DataUseCase
import Repository

enum SearchStationsFactory {
    static func makeClient() -> SearchStationsClient {
        let repository = LocationSearchRepositoryImpl()
        let useCase = SearchStationsUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
```

규칙:
- `enum` 으로 정의해 인스턴스화 금지
- `make{Client}() -> {Client}` 시그니처
- 실제 구현체 생성 → UseCase 조립 → `Client.live(useCase:)` 반환
- Feature/CoreDependencies 가 절대 모르는 영역

### App/Application — `BangawoApp.swift`

```swift
import SwiftUI
import ComposableArchitecture
import CoreDependencies
import RootFeature

@main
struct BangawoApp: App {
    private let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    init() {
        prepareDependencies {
            $0.searchStationsClient = SearchStationsFactory.makeClient()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
```

규칙:
- `init()` 에서 `prepareDependencies` 한 번만 호출
- 모든 live Client 는 여기서 주입
- Store 생성부에서 `withDependencies` 반복 금지 (App 단계 주입으로 충분)

### Presentation/Feature — 사용 예시

```swift
import ComposableArchitecture
import CoreDependencies
import Entity

@Reducer
public struct SearchFeature {
    @Dependency(\.searchStationsClient) private var searchStationsClient

    @ObservableState
    public struct State: Equatable {
        public var keyword = ""
        public var stations: [Station] = []
    }

    public enum Action {
        case keywordChanged(String)
        case searchTriggered
        case stationsResponse(Result<[Station], Error>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .keywordChanged(keyword):
                state.keyword = keyword
                return .none

            case .searchTriggered:
                let client = searchStationsClient
                let keyword = state.keyword
                return .run { send in
                    do {
                        let stations = try await client.searchStations(keyword: keyword)
                        await send(.stationsResponse(.success(stations)))
                    } catch {
                        await send(.stationsResponse(.failure(error)))
                    }
                }

            case let .stationsResponse(.success(stations)):
                state.stations = stations
                return .none

            case .stationsResponse(.failure):
                return .none
            }
        }
    }
}
```

규칙:
- 외부 의존은 `@Dependency` 로만
- `Effect.run` 안에서는 `state` 전체를 캡처하지 않고 필요한 값만 추출 후 캡처 (`@ObservableState` 호환)
- SDK/API/Repository/UseCaseImpl 직접 생성 금지
- `Data` 계열 모듈 import 금지

## 6. Store 생성

```swift
let store = Store(initialState: SearchFeature.State()) {
    SearchFeature()
}
```

App 시작 시 `prepareDependencies` 로 live 가 주입되므로 Store 생성부에서는 별도 `withDependencies` 를 반복하지 않는다.

## 7. 테스트 override

```swift
let store = TestStore(initialState: SearchFeature.State()) {
    SearchFeature()
} withDependencies: {
    $0.searchStationsClient.searchStations = { _ in
        [
            Station(
                id: "test-1",
                name: "테스트역",
                addressName: "서울 어딘가",
                roadAddressName: "테스트로 1",
                x: 127.0,
                y: 37.5
            )
        ]
    }
}
```

규칙:
- 필요한 클로저만 override (전체 client 교체 금지)
- 실제 SDK/API 호출 없이 Feature 로직만 검증

## 8. 의존성 규칙

허용:

```text
Presentation     → CoreDependencies
Presentation     → Domain (Entity, UseCase, DomainInterface)
CoreDependencies → Domain (Entity, UseCase)
Data             → Domain (Entity, DomainInterface, DataInterface, UseCase)
Data             → Network
App              → Presentation
App              → CoreDependencies
App              → Data
```

금지:

```text
Presentation     → Data
CoreDependencies → Data
CoreDependencies → Network
Data             → CoreDependencies
Domain           → Data
Domain           → Network
```

주의: `App → Data` 는 Composition Root 라 허용된다.

## 9. 금지 사항

- Feature 안에서 `LocationSearchRepositoryImpl()` 등 Impl 직접 생성
- Feature 안에서 `NetworkManager`, `URLSession` 직접 호출
- Feature 안에서 SDK(Kakao 등) 직접 import
- `CoreDependencies` 에서 `Repository` / `DataUseCase` / `Service` / `Model` / `API` import
- `CoreDependencies` 의 `liveValue` 에서 실제 구현체 조립 (반드시 `App/Factory` 에서)
- `Data` DTO 를 Domain `DataInterface` / Feature 인터페이스로 노출
- DTO 안에 Entity 변환을 넘는 비즈니스 로직 작성
- `static func live(useCase:)` 의 인자로 Repository/Service 직접 받기 (Domain UseCase protocol 만 허용)

## 10. 한 줄 규칙 요약

- Feature 는 `@Dependency` 로만 사용한다
- TCA Dependency Client (`@DependencyClient` + `DependencyKey` + `DependencyValues`) 는 `CoreDependencies` 한 파일에 둔다
- `liveValue` / `testValue` 는 빈 `Self()` 로 둔다
- `static func live(useCase:)` 팩토리는 Domain UseCase protocol 만 받는다
- UseCase protocol 은 `Domain/UseCase`, Repository protocol 은 `Domain/DataInterface` 에 둔다
- `*UseCaseImpl` 은 `Data/DataUseCase`, `*RepositoryImpl` 은 `Data/Repository`, SDK 어댑터는 `Data/Service` 에 둔다
- 실제 live 조립은 `App/Sources/Factory/{X}Factory.makeClient()` 에서만 한다
- 앱 시작 시 `BangawoApp.init()` 의 `prepareDependencies` 에서 모든 live client 를 주입한다
- 테스트는 `TestStore(... withDependencies:)` 로 필요한 클로저만 override 한다
