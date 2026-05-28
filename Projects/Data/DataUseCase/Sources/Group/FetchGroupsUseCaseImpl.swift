//
//  FetchGroupsUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchGroupsUseCaseImpl: FetchGroupsUseCase {
    private let repository: GroupRepositoryProtocol

    public init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Group] {
        try await repository.fetchGroups()
    }
}
