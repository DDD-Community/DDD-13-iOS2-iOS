//
//  PlaceOptionsClient.swift
//  CoreDependencies
//

import ComposableArchitecture
import DomainInterface
import UseCase

@DependencyClient
public struct PlaceOptionsClient: Sendable {
    public var fetchVibes: @Sendable () async throws -> [String]
}

public extension PlaceOptionsClient {
    static func live(useCase: any FetchPlaceVibesUseCase) -> Self {
        Self(fetchVibes: { try await useCase.execute() })
    }
}

extension PlaceOptionsClient: DependencyKey {
    public static var liveValue: PlaceOptionsClient {
        PlaceOptionsClient(fetchVibes: { throw PlaceOptionsClientError.notImplemented })
    }

    public static let testValue = PlaceOptionsClient()
}

public extension DependencyValues {
    var placeOptionsClient: PlaceOptionsClient {
        get { self[PlaceOptionsClient.self] }
        set { self[PlaceOptionsClient.self] = newValue }
    }
}
