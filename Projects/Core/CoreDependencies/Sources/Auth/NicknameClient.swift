//
//  NicknameClient.swift
//  CoreDependencies
//
//

import ComposableArchitecture

import DomainInterface
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
    public static var liveValue: NicknameClient {
        NicknameClient(
            validate: { _ in throw NicknameClientError.notImplemented }
        )
    }

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
