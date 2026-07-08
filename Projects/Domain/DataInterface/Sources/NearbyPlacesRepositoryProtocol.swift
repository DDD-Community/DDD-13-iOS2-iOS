//
//  NearbyPlacesRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol NearbyPlacesRepositoryProtocol: Sendable {
    func fetchNearbyPlaces(
        latitude: Double,
        longitude: Double,
        radiusMeters: Double,
        category: String?
    ) async throws -> [NearbyPlace]
}
