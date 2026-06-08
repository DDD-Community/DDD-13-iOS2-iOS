//
//  CreateGroupUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class CreateGroupUseCaseImpl: CreateGroupUseCase {
    private let repository: GroupRepositoryProtocol

    public init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(name: String, themeTagCode: String) async throws -> CreateGroupResult {
        try await repository.createGroup(name: name, themeTagCode: themeTagCode)
    }
}
