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
        public let latitude: Double
        public let longitude: Double
        // TODO: 백엔드 추천 응답에 주차/예약 필드 추가 시 optional 제거
        public let hasParking: Bool?
        public let reservable: Bool?
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
            score: score,
            nearestStationId: nearestStationId,
            latitude: place.latitude,
            longitude: place.longitude,
            hasParking: place.hasParking,
            reservable: place.reservable
        )
    }
}
