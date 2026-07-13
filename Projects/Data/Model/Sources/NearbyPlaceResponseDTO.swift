//
//  NearbyPlaceResponseDTO.swift
//  Model
//

import Entity

public struct NearbyPlaceResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let name: String
    public let categoryLabel: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let vibe: [String]
    public let occasion: [String]
    public let reservable: Bool
    public let hasParking: Bool
    public let rating: Double
    public let distanceMeters: Double
}

public extension NearbyPlaceResponseDTO {
    func toEntity() -> NearbyPlace {
        NearbyPlace(
            placeId: placeId,
            name: name,
            categoryLabel: PlaceCategory(categoryLabel: categoryLabel),
            address: address,
            latitude: latitude,
            longitude: longitude,
            vibe: vibe,
            occasion: occasion,
            reservable: reservable,
            hasParking: hasParking,
            rating: rating,
            distanceMeters: distanceMeters
        )
    }
}
