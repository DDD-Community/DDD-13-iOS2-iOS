//
//  PlaceRecommendationRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol PlaceRecommendationRepositoryProtocol: Sendable {
    func startPlaceRecommendation(meetingId: Int, radiusKm: Double) async throws
    func fetchRecommendations(meetingId: Int) async throws -> [RecommendedPlace]
}
