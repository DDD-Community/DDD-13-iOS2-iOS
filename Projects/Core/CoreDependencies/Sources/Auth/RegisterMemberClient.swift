//
//  RegisterMemberClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

@DependencyClient
public struct RegisterMemberClient: Sendable {
    public var register: @Sendable (_ member: RegisterMember) async throws -> RegisterMemberResult
}

public extension RegisterMemberClient {
    static func live(useCase: RegisterMemberUseCase) -> Self {
        Self { member in
            try await useCase.execute(
                member
            )
        }
    }
}

extension RegisterMemberClient: DependencyKey {
    public static var liveValue: RegisterMemberClient {
        RegisterMemberClient(
            register: { _ in throw RegisterMemberClientError.notImplemented }
        )
    }

    public static let testValue = RegisterMemberClient(
        register: { _ in
            RegisterMemberResult(
                id: 0,
                nickname: "",
                profileImageUrl: nil,
                socialProvider: "",
                registrationCompleted: true
            )
        }
    )
}

public extension DependencyValues {
    var registerMemberClient: RegisterMemberClient {
        get { self[RegisterMemberClient.self] }
        set { self[RegisterMemberClient.self] = newValue }
    }
}
