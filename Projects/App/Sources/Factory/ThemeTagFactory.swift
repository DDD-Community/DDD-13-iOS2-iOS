//
//  ThemeTagFactory.swift
//  Bangawo
//
//  Created by khyeji98 on 2026-06-04.
//

import CoreDependencies
import DataUseCase
import Repository

/// 모임 목적(테마) Client 의 Composition Root.
enum ThemeTagFactory {
    static func makeClient() -> ThemeTagClient {
        let repository = ThemeTagRepositoryImpl()
        let useCase = FetchThemeTagsUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
