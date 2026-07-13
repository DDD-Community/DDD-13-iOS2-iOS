//
//  FetchNearbyPlacesUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchNearbyPlacesUseCaseImpl: FetchNearbyPlacesUseCase {
    private let repository: NearbyPlacesRepositoryProtocol

    public init(repository: NearbyPlacesRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        latitude: Double,
        longitude: Double,
        radiusMeters: Double,
        category: String?
    ) async throws -> [NearbyPlace] {
        try await repository.fetchNearbyPlaces(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
            category: category
        )
    }
}
