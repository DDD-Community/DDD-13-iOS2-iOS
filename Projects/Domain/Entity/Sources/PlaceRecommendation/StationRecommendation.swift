//
//  StationRecommendation.swift
//  Entity
//

import Foundation

public struct StationRecommendation: Equatable, Sendable, Identifiable {
    public let station: MidpointStation
    public let places: [RecommendedPlace]

    public var id: Int { station.id }

    public init(
        station: MidpointStation,
        places: [RecommendedPlace]
    ) {
        self.station = station
        self.places = places
    }
}
