//
//  CloseGroupUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class CloseGroupUseCaseImpl: CloseGroupUseCase {
    private let repository: GroupRepositoryProtocol

    public init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(groupId: Int) async throws {
        try await repository.closeGroup(groupId: groupId)
    }
}
