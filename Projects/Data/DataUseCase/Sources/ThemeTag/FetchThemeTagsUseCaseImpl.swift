//
//  FetchThemeTagsUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchThemeTagsUseCaseImpl: FetchThemeTagsUseCase {
    private let repository: ThemeTagRepositoryProtocol

    public init(repository: ThemeTagRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [ThemeTag] {
        try await repository.fetchThemeTags()
    }
}
