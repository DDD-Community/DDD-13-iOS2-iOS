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
        public let roadAddress: String?
        public let latitude: Double
        public let longitude: Double
        public let vibe: [String]
        public let occasion: [String]
        public let reservable: Bool
        public let hasParking: Bool
        public let rating: Double
        public let businessHours: String?
        public let holiday: String?
        public let naverUrl: String
    }
}

public extension RecommendedPlaceResponseDTO {
    func toEntity() -> RecommendedPlace {
        RecommendedPlace(
            rank: rank,
            placeId: place.placeId,
            name: place.name,
            categoryLabel: PlaceCategory(categoryLabel: place.categoryLabel),
            address: place.address,
            roadAddress: place.roadAddress,
            score: score,
            nearestStationId: nearestStationId,
            latitude: place.latitude,
            longitude: place.longitude,
            vibe: place.vibe,
            occasion: place.occasion,
            reservable: place.reservable,
            hasParking: place.hasParking,
            rating: place.rating,
            businessHours: place.businessHours,
            holiday: place.holiday,
            naverUrl: place.naverUrl
        )
    }
}
