import ComposableArchitecture
import UseCase

@DependencyClient
public struct SessionClient: Sendable {
    public var logout: @Sendable () async -> Void
}

public extension SessionClient {
    static func live(useCase: any LogoutUseCase) -> Self {
        Self(logout: { await useCase.execute() })
    }
}

extension SessionClient: DependencyKey {
    public static let liveValue = Self()
    public static let testValue = Self()
}

public extension DependencyValues {
    var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}
