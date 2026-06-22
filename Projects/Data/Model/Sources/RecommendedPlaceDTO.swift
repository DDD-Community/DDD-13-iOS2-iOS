//
//  RecommendedPlaceDTO.swift
//  Model
//

import Entity

public struct RecommendedPlaceResponseDTO: Decodable, Sendable {
    public let rank: Int
    public let place: PlaceDTO
    public let score: Double
    public let nearestStationId: Int

    public struct PlaceDTO: Decodable, Sendable {
        public let placeId: Int
        public let name: String
        public let categoryLabel: String
        public let address: String
    }
}

public extension RecommendedPlaceResponseDTO {
    func toEntity() -> RecommendedPlace {
        RecommendedPlace(
            rank: rank,
            placeId: place.placeId,
            name: place.name,
            categoryLabel: place.categoryLabel,
            address: place.address,
            score: score,
            nearestStationId: nearestStationId
        )
    }
}
