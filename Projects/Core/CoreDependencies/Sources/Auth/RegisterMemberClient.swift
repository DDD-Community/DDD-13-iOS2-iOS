//
//  RegisterMemberClient.swift
//  CoreDependencies
//

import ComposableArchitecture
import Entity
import UseCase

@DependencyClient
public struct RegisterMemberClient: Sendable {
    public var register: @Sendable (_ nickname: String, _ agreedTermsIds: [Int], _ departureLabel: String, _ departureAddress: String, _ latitude: Double, _ longitude: Double) async throws -> RegisterMemberResult
}

public extension RegisterMemberClient {
    static func live(useCase: RegisterMemberUseCase) -> Self {
        Self { nickname, agreedTermsIds, departureLabel, departureAddress, latitude, longitude in
            try await useCase.execute(
                nickname: nickname,
                agreedTermsIds: agreedTermsIds,
                departureLabel: departureLabel,
                departureAddress: departureAddress,
                latitude: latitude,
                longitude: longitude
            )
        }
    }
}

extension RegisterMemberClient: DependencyKey {
    public static let liveValue = RegisterMemberClient()
    public static let testValue = RegisterMemberClient(
        register: { _, _, _, _, _, _ in
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
