//
//  MidpointStation.swift
//  Entity
//

import Foundation

public struct MidpointStation: Equatable, Sendable, Identifiable {
    public let stationId: Int
    public let rank: Int
    public let stationName: String
    public let lines: String
    public let distanceKm: Double
    public let latitude: Double
    public let longitude: Double

    public var id: Int { rank }

    public init(
        stationId: Int,
        rank: Int,
        stationName: String,
        lines: String,
        distanceKm: Double,
        latitude: Double,
        longitude: Double
    ) {
        self.stationId = stationId
        self.rank = rank
        self.stationName = stationName
        self.lines = lines
        self.distanceKm = distanceKm
        self.latitude = latitude
        self.longitude = longitude
    }
}
