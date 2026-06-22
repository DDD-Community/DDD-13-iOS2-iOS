//
//  PlaceRecommendationRepositoryProtocol.swift
//  DataInterface
//

public protocol PlaceRecommendationRepositoryProtocol: Sendable {
    func startPlaceRecommendation(meetingId: Int, radiusKm: Double) async throws
}
