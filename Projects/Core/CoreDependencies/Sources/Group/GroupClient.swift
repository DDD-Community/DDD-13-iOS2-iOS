//
//  GroupClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

@DependencyClient
public struct GroupClient: Sendable {
    public var fetchGroups: @Sendable () async throws -> [Group]
    public var createGroup: @Sendable (_ name: String, _ themeTagCode: String) async throws -> CreateGroupResult
}

public extension GroupClient {
    static func live(
        fetchUseCase: any FetchGroupsUseCase,
        createUseCase: any CreateGroupUseCase
    ) -> Self {
        Self(
            fetchGroups: { try await fetchUseCase.execute() },
            createGroup: { name, themeTagCode in
                try await createUseCase.execute(name: name, themeTagCode: themeTagCode)
            }
        )
    }
}

extension GroupClient: DependencyKey {
    public static var liveValue: GroupClient {
        GroupClient(
            fetchGroups: { throw GroupClientError.notImplemented },
            createGroup: { _, _ in throw GroupClientError.notImplemented }
        )
    }

    public static let testValue: GroupClient = GroupClient()
}

public extension DependencyValues {
    var groupClient: GroupClient {
        get { self[GroupClient.self] }
        set { self[GroupClient.self] = newValue }
    }
}
