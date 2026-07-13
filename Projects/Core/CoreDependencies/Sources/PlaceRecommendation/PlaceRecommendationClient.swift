//
//  PlaceRecommendationClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

@DependencyClient
public struct PlaceRecommendationClient: Sendable {
    public var startPlaceRecommendation: @Sendable (_ meetingId: Int, _ radiusKm: Double) async throws -> Void
    public var fetchStationRecommendations: @Sendable (_ meetingId: Int) async throws -> [StationRecommendation]
}

public extension PlaceRecommendationClient {
    static func live(
        startPlaceRecommendationUseCase: any StartPlaceRecommendationUseCase,
        fetchUseCase: any FetchStationRecommendationsUseCase
    ) -> Self {
        Self(
            startPlaceRecommendation: { meetingId, radiusKm in
                try await startPlaceRecommendationUseCase.execute(meetingId: meetingId, radiusKm: radiusKm)
            },
            fetchStationRecommendations: { meetingId in
                try await fetchUseCase.execute(meetingId: meetingId)
            }
        )
    }
}

extension PlaceRecommendationClient: DependencyKey {
    public static var liveValue: PlaceRecommendationClient {
        PlaceRecommendationClient(
            startPlaceRecommendation: { _, _ in throw PlaceRecommendationClientError.notImplemented },
            fetchStationRecommendations: { _ in throw PlaceRecommendationClientError.notImplemented }
        )
    }

    public static let testValue: PlaceRecommendationClient = PlaceRecommendationClient()

    public static let previewValue: PlaceRecommendationClient = PlaceRecommendationClient(
        startPlaceRecommendation: { _, _ in },
        fetchStationRecommendations: { _ in [] }
    )
}

public extension DependencyValues {
    var placeRecommendationClient: PlaceRecommendationClient {
        get { self[PlaceRecommendationClient.self] }
        set { self[PlaceRecommendationClient.self] = newValue }
    }
}
