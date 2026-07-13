//
//  GroupInvitationShareClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import Entity
import UseCase

@DependencyClient
public struct GroupInvitationShareClient: Sendable {
    public var share: @Sendable (_ invitation: GroupInvitation) async throws -> Void
}

public extension GroupInvitationShareClient {
    static func live(useCase: any ShareGroupInvitationUseCase) -> Self {
        Self(
            share: { invitation in
                try await useCase.execute(invitation: invitation)
            }
        )
    }
}

extension GroupInvitationShareClient: DependencyKey {
    public static let liveValue: GroupInvitationShareClient = GroupInvitationShareClient()
    public static let testValue: GroupInvitationShareClient = GroupInvitationShareClient()
}

public extension DependencyValues {
    var groupInvitationShareClient: GroupInvitationShareClient {
        get { self[GroupInvitationShareClient.self] }
        set { self[GroupInvitationShareClient.self] = newValue }
    }
}
