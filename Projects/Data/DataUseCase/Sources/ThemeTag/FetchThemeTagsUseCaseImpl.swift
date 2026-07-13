//
//  FetchThemeTagsUseCaseImpl.swift
//  DataUseCase
//
//  Created by khyeji98 on 2026-06-04.
//

import DataInterface
import Entity
import UseCase

/// 모임 목적(테마) 목록 조회 UseCase 구현체.
public final class FetchThemeTagsUseCaseImpl: FetchThemeTagsUseCase {
    private let repository: ThemeTagRepositoryProtocol

    public init(repository: ThemeTagRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [ThemeTag] {
        try await repository.fetchThemeTags()
    }
}
