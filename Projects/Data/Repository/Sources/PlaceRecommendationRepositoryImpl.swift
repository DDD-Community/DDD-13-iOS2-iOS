//
//  PlaceRecommendationRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Model
import Networking

public final class PlaceRecommendationRepositoryImpl: PlaceRecommendationRepositoryProtocol {
    public init() {}

    public func startPlaceRecommendation(meetingId: Int, radiusKm: Double) async throws {
        let requestDTO = StartPlaceRecommendationRequestDTO(radiusKm: radiusKm)
        try await NetworkManager.shared.requestVoid(
            PlaceRecommendationEndpoint.start(meetingId: meetingId, requestDTO)
        )
    }

    public func fetchRecommendations(meetingId: Int) async throws -> [RecommendedPlace] {
        let response: [RecommendedPlaceResponseDTO] = try await NetworkManager.shared.request(
            PlaceRecommendationEndpoint.fetchRecommendations(meetingId: meetingId)
        )

        return response.map { $0.toEntity() }
    }
}
