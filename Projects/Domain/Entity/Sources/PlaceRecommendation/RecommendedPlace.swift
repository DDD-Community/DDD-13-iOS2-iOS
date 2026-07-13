//
//  RecommendedPlace.swift
//  Entity
//

import Foundation

public struct RecommendedPlace: Equatable, Sendable, Identifiable {
    public let rank: Int
    public let placeId: Int
    public let name: String
    public let categoryLabel: PlaceCategory
    public let address: String
    public let roadAddress: String?
    public let score: Double
    public let nearestStationId: Int
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

    public var id: Int { placeId }

    public init(
        rank: Int,
        placeId: Int,
        name: String,
        categoryLabel: PlaceCategory,
        address: String,
        roadAddress: String?,
        score: Double,
        nearestStationId: Int,
        latitude: Double,
        longitude: Double,
        vibe: [String],
        occasion: [String],
        reservable: Bool,
        hasParking: Bool,
        rating: Double,
        businessHours: String?,
        holiday: String?,
        naverUrl: String
    ) {
        self.rank = rank
        self.placeId = placeId
        self.name = name
        self.categoryLabel = categoryLabel
        self.address = address
        self.roadAddress = roadAddress
        self.score = score
        self.nearestStationId = nearestStationId
        self.latitude = latitude
        self.longitude = longitude
        self.vibe = vibe
        self.occasion = occasion
        self.reservable = reservable
        self.hasParking = hasParking
        self.rating = rating
        self.businessHours = businessHours
        self.holiday = holiday
        self.naverUrl = naverUrl
    }
}
