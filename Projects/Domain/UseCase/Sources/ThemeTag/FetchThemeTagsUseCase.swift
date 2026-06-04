//
//  FetchThemeTagsUseCase.swift
//  UseCase
//

import Entity

public protocol FetchThemeTagsUseCase: Sendable {
    func execute() async throws -> [ThemeTag]
}
