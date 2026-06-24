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
    public let score: Double
    public let nearestStationId: Int

    public var id: Int { placeId }

    public init(
        rank: Int,
        placeId: Int,
        name: String,
        categoryLabel: PlaceCategory,
        address: String,
        score: Double,
        nearestStationId: Int
    ) {
        self.rank = rank
        self.placeId = placeId
        self.name = name
        self.categoryLabel = categoryLabel
        self.address = address
        self.score = score
        self.nearestStationId = nearestStationId
    }
}
