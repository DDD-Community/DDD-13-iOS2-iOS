//
//  ConfirmedPlaceResult.swift
//  Entity
//

import Foundation

public struct ConfirmedPlace: Equatable, Sendable {
    public let placeId: Int
    public let name: String
    public let categoryLabel: PlaceCategory
    public let address: String
    public let latitude: Double
    public let longitude: Double

    public init(
        placeId: Int,
        name: String,
        categoryLabel: PlaceCategory,
        address: String,
        latitude: Double,
        longitude: Double
    ) {
        self.placeId = placeId
        self.name = name
        self.categoryLabel = categoryLabel
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct ConfirmedPlaceResult: Equatable, Sendable {
    public let place: ConfirmedPlace
    public let confirmedAt: String
    public let candidates: [ConfirmedPlaceCandidate]

    public init(
        place: ConfirmedPlace,
        confirmedAt: String,
        candidates: [ConfirmedPlaceCandidate]
    ) {
        self.place = place
        self.confirmedAt = confirmedAt
        self.candidates = candidates
    }
}

public struct ConfirmedPlaceCandidate: Equatable, Sendable {
    public let rank: Int
    public let place: ConfirmedPlace
    public let voteCount: Int
    public let totalSeconds: Int
    public let totalTransfers: Int

    public init(
        rank: Int,
        place: ConfirmedPlace,
        voteCount: Int,
        totalSeconds: Int,
        totalTransfers: Int
    ) {
        self.rank = rank
        self.place = place
        self.voteCount = voteCount
        self.totalSeconds = totalSeconds
        self.totalTransfers = totalTransfers
    }
}
