//
//  NearbyPlacesRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Model
import Networking

public final class NearbyPlacesRepositoryImpl: NearbyPlacesRepositoryProtocol {
    public init() {}

    public func fetchNearbyPlaces(
        latitude: Double,
        longitude: Double,
        radiusMeters: Double,
        category: String?
    ) async throws -> [NearbyPlace] {
        let response: [NearbyPlaceResponseDTO] = try await NetworkManager.shared.request(
            PlacesNearbyEndpoint.fetch(
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                category: category
            )
        )

        return response.map { $0.toEntity() }
    }
}
