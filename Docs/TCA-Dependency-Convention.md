# TCA Dependency 컨벤션

## 1. 목적

우리 프로젝트는 TCA에서 의존성을 struct-based client 패턴으로 통일한다.

목표:
- Feature가 구현 세부사항을 모르도록 한다
- 테스트/프리뷰에서 의존성 override를 쉽게 한다
- Domain UseCase와 TCA Dependency Client의 역할을 분리한다
- 실제 구현체 조립은 App의 Composition Root에서 수행한다
- Presentation이 Data 계층 구현체에 직접/간접 의존하지 않도록 한다

## 2. 폴더 구조

```text
Core/
  Dependencies/
    SocialAuthClient.swift

Domain/
  Entity/
    AuthToken.swift
    SocialAuthProvider.swift
  UseCase/
    SignInWithSocialUseCase.swift
  DataInterface/
    AuthRepositoryProtocol.swift
  DomainInterface/
    SocialAuthClientError.swift

Data/
  Model/
    AuthDTO.swift
  API/
    AuthEndPoint.swift
  Service/
    KakaoLoginService.swift
  Repository/
    AuthRepositoryImpl.swift
  UseCase/
    SignInWithSocialUseCaseImpl.swift

App/
  Auth/
    AuthAssembly.swift

Presentation/
  Login/
    LoginFeature.swift
    LoginView.swift
```

## 3. 레이어별 책임

### Presentation / Feature

- `@Dependency`로만 외부 의존성 사용
- SDK/API 직접 호출 금지
- 구현체 직접 생성 금지
- Data 계층 모듈 import 금지
- View는 사용자 이벤트를 Feature Action으로 전달

### Core/Dependencies

- TCA struct-based client 정의
- `DependencyValues` 등록
- `DependencyKey.liveValue`, `testValue` 기본값 제공
- Domain UseCase protocol을 호출하는 adapter 제공
- Data 계층 구현체 import 금지
- Assembly 또는 구현체 조립 금지

### Domain

- Entity 정의
- UseCase protocol 정의
- Repository protocol 정의
- 외부 SDK/네트워크 타입 금지
- DTO 노출 금지

### Data

- 실제 구현 담당
- SDK 호출
- API 호출
- DTO 정의
- RepositoryImpl
- UseCaseImpl
- DTO -> Entity 변환은 Repository 내부 또는 Repository 전용 mapper에서 수행

### App

- Composition Root
- 실제 live dependency 조립
- `AuthAssembly` 위치
- 앱 시작 시 TCA dependency live 구현 주입
- DataUseCase, Repository, Service 등 구현체 의존 가능

## 4. 파일 예시

### Core/Dependencies/SocialAuthClient.swift

```swift
import ComposableArchitecture
import DomainInterface
import Entity
import UseCase

public struct SocialAuthClient: Sendable {
    public var signIn: @Sendable (SocialAuthProvider) async throws -> AuthToken

    public init(
        signIn: @escaping @Sendable (SocialAuthProvider) async throws -> AuthToken
    ) {
        self.signIn = signIn
    }
}

public extension SocialAuthClient {
    static func live(useCase: SignInWithSocialUseCase) -> Self {
        Self { provider in
            try await useCase.execute(provider: provider)
        }
    }
}

extension SocialAuthClient: DependencyKey {
    public static var liveValue: SocialAuthClient {
        SocialAuthClient { provider in
            throw SocialAuthClientError.notImplemented(provider)
        }
    }

    public static var testValue: SocialAuthClient {
        SocialAuthClient { provider in
            throw SocialAuthClientError.notImplemented(provider)
        }
    }
}

public extension DependencyValues {
    var socialAuthClient: SocialAuthClient {
        get { self[SocialAuthClient.self] }
        set { self[SocialAuthClient.self] = newValue }
    }
}
```

역할:
- Feature가 사용하는 TCA dependency client
- Domain UseCase protocol과 Feature 사이의 adapter
- 실제 구현체를 직접 생성하지 않음
- `liveValue`는 주입 누락을 빠르게 발견하기 위한 기본값

### Domain/Entity/SocialAuthProvider.swift

```swift
public enum SocialAuthProvider: Equatable, Sendable {
    case kakao
    case apple
    case naver
}

public extension SocialAuthProvider {
    var serverValue: String {
        switch self {
        case .kakao:
            return "KAKAO"
        case .apple:
            return "APPLE"
        case .naver:
            return "NAVER"
        }
    }
}
```

역할:
- 소셜 로그인 타입 정의
- SDK 독립적인 도메인 모델

### Domain/Entity/AuthToken.swift

```swift
public struct AuthToken: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let isNewMember: Bool
    public let registrationCompleted: Bool

    public init(
        accessToken: String,
        refreshToken: String,
        isNewMember: Bool,
        registrationCompleted: Bool
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isNewMember = isNewMember
        self.registrationCompleted = registrationCompleted
    }
}
```

역할:
- 서버 로그인 결과를 표현하는 도메인 모델
- DTO가 아닌 Feature/Domain에서 사용하는 Entity

### Domain/UseCase/SignInWithSocialUseCase.swift

```swift
import Entity

public protocol SignInWithSocialUseCase: Sendable {
    func execute(provider: SocialAuthProvider) async throws -> AuthToken
}
```

역할:
- 로그인 유스케이스 인터페이스
- Presentation과 Data 구현체 사이의 Domain 추상화

### Domain/DataInterface/AuthRepositoryProtocol.swift

```swift
import Entity

public protocol AuthRepositoryProtocol: Sendable {
    func login(
        provider: String,
        providerToken: String
    ) async throws -> AuthToken
}
```

역할:
- 서버 인증용 repository protocol
- DTO를 반환하지 않고 Entity를 반환
- Domain 계층이 Data DTO를 알지 않도록 함

### Data/Model/AuthDTO.swift

```swift
public struct LoginRequestDTO: Encodable, Sendable {
    public let provider: String
    public let providerToken: String
}

public struct LoginResponseDTO: Decodable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let isNewMember: Bool
    public let registrationCompleted: Bool
}
```

역할:
- 서버 요청/응답 형태만 표현
- Entity 변환 로직 포함 금지
- Domain 타입 import 금지

### Data/Repository/AuthRepositoryImpl.swift

```swift
import API
import DataInterface
import Entity
import Model
import Networking

public struct AuthRepositoryImpl: AuthRepositoryProtocol {
    public init() {}

    public func login(
        provider: String,
        providerToken: String
    ) async throws -> AuthToken {
        let requestDTO = LoginRequestDTO(
            provider: provider,
            providerToken: providerToken
        )

        let response: LoginResponseDTO = try await NetworkManager.shared.request(
            AuthEndPoint.login(requestDTO)
        )

        return response.toEntity()
    }
}

private extension LoginResponseDTO {
    func toEntity() -> AuthToken {
        AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewMember: isNewMember,
            registrationCompleted: registrationCompleted
        )
    }
}
```

역할:
- `AuthRepositoryProtocol` 구현체
- API 호출
- DTO -> Entity 변환을 Repository 내부에서 수행
- DTO가 Domain을 알지 않도록 보호

### Data/Service/KakaoLoginService.swift

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
        // 실제 Kakao SDK 호출
    }
}
```

역할:
- Kakao SDK 직접 호출
- SDK 응답을 앱 공통 모델로 변환
- SDK 디테일을 외부로 숨김

### Data/UseCase/SignInWithSocialUseCaseImpl.swift

```swift
import DataInterface
import DomainInterface
import Entity
import Service
import UseCase

public final class SignInWithSocialUseCaseImpl: SignInWithSocialUseCase {
    private let repository: AuthRepositoryProtocol
    private let kakaoLoginService: KakaoLoginServiceInterface

    public init(
        repository: AuthRepositoryProtocol,
        kakaoLoginService: KakaoLoginServiceInterface
    ) {
        self.repository = repository
        self.kakaoLoginService = kakaoLoginService
    }

    public func execute(provider: SocialAuthProvider) async throws -> AuthToken {
        switch provider {
        case .kakao:
            let socialToken = try await kakaoLoginService.login()
            return try await repository.login(
                provider: provider.serverValue,
                providerToken: socialToken.accessToken
            )

        case .apple, .naver:
            throw SocialAuthClientError.notImplemented(provider)
        }
    }
}
```

역할:
- 소셜 SDK 로그인 + 서버 로그인 흐름 조합
- Domain UseCase protocol 구현
- Feature가 알 필요 없는 비즈니스 흐름 수행

### App/Auth/AuthAssembly.swift

```swift
import CoreDependencies
import DataUseCase
import Repository
import Service

enum AuthAssembly {
    static func makeSocialAuthClient() -> SocialAuthClient {
        let repository = AuthRepositoryImpl()
        let useCase = SignInWithSocialUseCaseImpl(
            repository: repository,
            kakaoLoginService: KakaoLoginService()
        )

        return .live(useCase: useCase)
    }
}
```

역할:
- App의 Composition Root
- 실제 live dependency 조립
- Data 계층 구현체 생성
- Feature/CoreDependencies가 구현체를 모르도록 연결

### App/BangawoApp.swift

```swift
import ComposableArchitecture
import Presentation

@main
struct BangawoApp: App {
    init() {
        prepareDependencies {
            $0.socialAuthClient = AuthAssembly.makeSocialAuthClient()
        }
    }

    var body: some Scene {
        WindowGroup {
            LoginView(
                store: Store(initialState: LoginFeature.State()) {
                    LoginFeature()
                }
            )
        }
    }
}
```

역할:
- 앱 시작 시 live dependency 주입
- Store 생성부에 반복적인 `withDependencies` 사용을 줄임

### Presentation/Login/LoginFeature.swift

```swift
import ComposableArchitecture
import CoreDependencies
import DomainInterface
import Entity

@Reducer
public struct LoginFeature {
    @Dependency(\.socialAuthClient) private var socialAuthClient

    @ObservableState
    public struct State: Equatable {
        public var isLoading = false
        public var error: String?
    }

    public enum Action {
        case kakaoLoginTapped
        case appleLoginTapped
        case naverLoginTapped
        case loginResponse(Result<AuthToken, SocialAuthClientError>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didLoginSuccess
            case needsSignUp(tempToken: String)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .kakaoLoginTapped:
                state.isLoading = true
                state.error = nil
                return signIn(provider: .kakao)

            case .appleLoginTapped:
                state.isLoading = true
                state.error = nil
                return signIn(provider: .apple)

            case .naverLoginTapped:
                state.isLoading = true
                state.error = nil
                return signIn(provider: .naver)

            case let .loginResponse(.success(authToken)):
                state.isLoading = false

                if !authToken.registrationCompleted {
                    return .send(.delegate(.needsSignUp(tempToken: authToken.accessToken)))
                } else {
                    return .send(.delegate(.didLoginSuccess))
                }

            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

private extension LoginFeature {
    func signIn(provider: SocialAuthProvider) -> Effect<Action> {
        let client = socialAuthClient

        return .run { send in
            do {
                let authToken = try await client.signIn(provider)
                await send(.loginResponse(.success(authToken)))
            } catch let error as SocialAuthClientError {
                await send(.loginResponse(.failure(error)))
            } catch {
                await send(.loginResponse(.failure(.underlying(error.localizedDescription))))
            }
        }
    }
}
```

역할:
- 외부 구현을 모르고 dependency만 사용
- SDK/API/Repository/UseCaseImpl 직접 생성 금지
- 로그인 결과에 따른 화면 전환 판단만 수행

## 5. Store 생성 예시

```swift
let store = Store(initialState: LoginFeature.State()) {
    LoginFeature()
}
```

설명:
- App 시작 시 `prepareDependencies`로 live 구현을 주입한다
- Feature Store 생성부에서는 별도 `withDependencies`를 반복하지 않는다

## 6. 테스트 override 예시

```swift
let store = TestStore(initialState: LoginFeature.State()) {
    LoginFeature()
} withDependencies: {
    $0.socialAuthClient.signIn = { _ in
        AuthToken(
            accessToken: "test-access",
            refreshToken: "test-refresh",
            isNewMember: false,
            registrationCompleted: true
        )
    }
}
```

설명:
- 테스트에서는 필요한 함수만 override
- 실제 SDK/API 호출 없이 Feature 로직만 검증한다

## 7. 의존성 규칙

허용:

```text
Presentation -> CoreDependencies
Presentation -> Domain
CoreDependencies -> Domain
Data -> Domain
App -> Presentation
App -> CoreDependencies
App -> Data
```

금지:

```text
Presentation -> Data
CoreDependencies -> Data
Data -> CoreDependencies
Domain -> Data
Domain -> Network
```

주의:

```text
App -> Data
```

는 허용된다. App은 Composition Root이므로 실제 구현체 조립을 위해 Data 계층을 알 수 있다.

## 8. 금지사항

- Feature에서 `KakaoLoginService()` 직접 생성 금지
- Feature에서 `AuthRepositoryImpl()` 직접 생성 금지
- Feature에서 `URLSession`, `NetworkManager` 직접 호출 금지
- CoreDependencies에서 DataUseCase/Repository/Service import 금지
- CoreDependencies의 `liveValue`에서 실제 구현체 조립 금지
- Data DTO를 Feature/Domain 인터페이스로 노출 금지
- DTO 내부에 Entity 변환 로직 작성 금지

## 9. 한 줄 규칙

- Feature는 `@Dependency`로만 사용한다
- TCA Dependency Client는 CoreDependencies에 둔다
- UseCase protocol은 Domain에 둔다
- UseCaseImpl/RepositoryImpl/Service는 Data에 둔다
- 실제 live 조립은 App의 Assembly에서 한다
- 앱 실행 시 App에서 dependency를 주입한다
- 테스트는 `withDependencies`로 override한다
