//
//  NicknameClient.swift
//  CoreDependencies
//
//

import ComposableArchitecture
import UseCase

@DependencyClient
public struct NicknameClient: Sendable {
    public var validate: @Sendable (_ nickname: String) async throws -> Void
}

public extension NicknameClient {
    static func live(useCase: ValidateNicknameUseCase) -> Self {
        Self { nickname in
            try await useCase.execute(nickname: nickname)
        }
    }
}

extension NicknameClient: DependencyKey {
    public static let liveValue = NicknameClient()
    public static let testValue = NicknameClient(
        validate: { _ in }
    )
}

public extension DependencyValues {
    var nicknameClient: NicknameClient {
        get { self[NicknameClient.self] }
        set { self[NicknameClient.self] = newValue }
    }
}
