//
//  ThemeTagClient.swift
//  CoreDependencies
//
//  Created by khyeji98 on 2026-06-04.
//

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

/// 모임 목적(테마) 조회를 위한 TCA Dependency Client.
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
    public static var liveValue: ThemeTagClient {
        ThemeTagClient(
            fetchThemeTags: { throw ThemeTagClientError.notImplemented }
        )
    }

    public static let testValue: ThemeTagClient = ThemeTagClient()
}

public extension DependencyValues {
    var themeTagClient: ThemeTagClient {
        get { self[ThemeTagClient.self] }
        set { self[ThemeTagClient.self] = newValue }
    }
}
