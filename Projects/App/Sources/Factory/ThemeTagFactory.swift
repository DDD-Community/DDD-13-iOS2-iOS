//
//  ThemeTagFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum ThemeTagFactory {
    static func makeClient() -> ThemeTagClient {
        let repository = ThemeTagRepositoryImpl()
        let useCase = FetchThemeTagsUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
