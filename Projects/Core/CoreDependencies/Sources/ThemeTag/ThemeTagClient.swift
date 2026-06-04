//
//  ThemeTagClient.swift
//  CoreDependencies
//

import ComposableArchitecture
import Entity
import UseCase

@DependencyClient
public struct ThemeTagClient: Sendable {
    public var fetchThemeTags: @Sendable () async throws -> [ThemeTag]
}

public extension ThemeTagClient {
    static func live(useCase: any FetchThemeTagsUseCase) -> Self {
        Self(
            fetchThemeTags: { try await useCase.execute() }
        )
    }
}

extension ThemeTagClient: DependencyKey {
    public static let liveValue: ThemeTagClient = ThemeTagClient()
    public static let testValue: ThemeTagClient = ThemeTagClient()
}

public extension DependencyValues {
    var themeTagClient: ThemeTagClient {
        get { self[ThemeTagClient.self] }
        set { self[ThemeTagClient.self] = newValue }
    }
}
