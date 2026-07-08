//
//  PlaceDetailResponseDTO.swift
//  Model
//

import Entity

public struct PlaceDetailResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let name: String
    public let categoryLabel: String
    public let address: String
    public let roadAddress: String
    public let latitude: Double
    public let longitude: Double
    public let vibe: [String]
    public let occasion: [String]
    public let reservable: Bool
    public let hasParking: Bool
    public let rating: Double
    public let businessHours: String
    public let holiday: String
    public let naverUrl: String
}

public extension PlaceDetailResponseDTO {
    func toEntity() -> PlaceDetail {
        PlaceDetail(
            placeId: placeId,
            name: name,
            categoryLabel: PlaceCategory(categoryLabel: categoryLabel),
            address: address,
            roadAddress: roadAddress,
            latitude: latitude,
            longitude: longitude,
            vibe: vibe,
            occasion: occasion,
            reservable: reservable,
            hasParking: hasParking,
            rating: rating,
            businessHours: businessHours,
            holiday: holiday,
            naverUrl: naverUrl
        )
    }
}
