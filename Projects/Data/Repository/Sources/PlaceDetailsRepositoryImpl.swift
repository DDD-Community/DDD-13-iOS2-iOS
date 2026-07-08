//
//  PlaceDetailsRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Model
import Networking

public final class PlaceDetailsRepositoryImpl: PlaceDetailsRepositoryProtocol {
    public init() {}

    public func fetchPlaceDetails(ids: [Int]) async throws -> [PlaceDetail] {
        let response: [PlaceDetailResponseDTO] = try await NetworkManager.shared.request(
            PlacesEndpoint.fetchDetails(ids: ids)
        )

        return response.map { $0.toEntity() }
    }
}
