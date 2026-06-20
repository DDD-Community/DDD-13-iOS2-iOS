//
//  PlaceRecommendationRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
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
}
