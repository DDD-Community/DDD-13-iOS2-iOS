//
//  FetchNearbyPlacesUseCase.swift
//  UseCase
//

import Entity

public protocol FetchNearbyPlacesUseCase: Sendable {
    func execute(
        latitude: Double,
        longitude: Double,
        radiusMeters: Double,
        category: String?
    ) async throws -> [NearbyPlace]
}
