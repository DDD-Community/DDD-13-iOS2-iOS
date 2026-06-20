//
//  PlaceRecommendationClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import DomainInterface
import UseCase

@DependencyClient
public struct PlaceRecommendationClient: Sendable {
    public var startPlaceRecommendation: @Sendable (_ meetingId: Int, _ radiusKm: Double) async throws -> Void
}

public extension PlaceRecommendationClient {
    static func live(startPlaceRecommendationUseCase: any StartPlaceRecommendationUseCase) -> Self {
        Self(
            startPlaceRecommendation: { meetingId, radiusKm in
                try await startPlaceRecommendationUseCase.execute(meetingId: meetingId, radiusKm: radiusKm)
            }
        )
    }
}

extension PlaceRecommendationClient: DependencyKey {
    public static var liveValue: PlaceRecommendationClient {
        PlaceRecommendationClient(
            startPlaceRecommendation: { _, _ in throw PlaceRecommendationClientError.notImplemented }
        )
    }

    public static let testValue: PlaceRecommendationClient = PlaceRecommendationClient()

    public static let previewValue: PlaceRecommendationClient = PlaceRecommendationClient(
        startPlaceRecommendation: { _, _ in }
    )
}

public extension DependencyValues {
    var placeRecommendationClient: PlaceRecommendationClient {
        get { self[PlaceRecommendationClient.self] }
        set { self[PlaceRecommendationClient.self] = newValue }
    }
}
