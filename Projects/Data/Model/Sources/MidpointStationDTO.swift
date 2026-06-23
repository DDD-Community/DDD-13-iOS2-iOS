//
//  MidpointStationDTO.swift
//  Model
//

import Entity

public struct MidpointStationsResponseDTO: Decodable, Sendable {
    public let candidates: [Candidate]

    public struct Candidate: Decodable, Sendable {
        public let rank: Int
        public let stationId: Int
        public let stationName: String
        public let lines: String
        public let distanceKm: Double
        public let latitude: Double
        public let longitude: Double
    }
}

public extension MidpointStationsResponseDTO.Candidate {
    func toEntity() -> MidpointStation {
        MidpointStation(
            stationId: stationId,
            rank: rank,
            stationName: stationName,
            lines: lines,
            distanceKm: distanceKm,
            latitude: latitude,
            longitude: longitude
        )
    }
}
