//
//  NearbyPlace.swift
//  Entity
//

import Foundation

public struct NearbyPlace: Equatable, Sendable, Identifiable {
    public let placeId: Int
    public let name: String
    public let categoryLabel: PlaceCategory
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let vibe: [String]
    public let occasion: [String]
    public let reservable: Bool
    public let hasParking: Bool
    public let rating: Double
    public let distanceMeters: Double

    public var id: Int { placeId }

    public init(
        placeId: Int,
        name: String,
        categoryLabel: PlaceCategory,
        address: String,
        latitude: Double,
        longitude: Double,
        vibe: [String],
        occasion: [String],
        reservable: Bool,
        hasParking: Bool,
        rating: Double,
        distanceMeters: Double
    ) {
        self.placeId = placeId
        self.name = name
        self.categoryLabel = categoryLabel
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.vibe = vibe
        self.occasion = occasion
        self.reservable = reservable
        self.hasParking = hasParking
        self.rating = rating
        self.distanceMeters = distanceMeters
    }
}
