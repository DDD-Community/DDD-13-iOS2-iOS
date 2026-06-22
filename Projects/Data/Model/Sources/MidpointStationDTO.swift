//
//  MidpointStationDTO.swift
//  Model
//

import Entity

public struct MidpointStationsResponseDTO: Decodable, Sendable {
    public let candidates: [Candidate]

    public struct Candidate: Decodable, Sendable {
        // TODO: 서버 응답에 stationId 추가 예정
        public let rank: Int
        public let stationName: String
        public let lines: String
        public let distanceKm: Double
    }
}

public extension MidpointStationsResponseDTO.Candidate {
    func toEntity() -> MidpointStation {
        MidpointStation(
            // TODO: 서버 응답에 stationId 추가 시 매핑 교체
            stationId: -1,
            rank: rank,
            stationName: stationName,
            lines: lines,
            distanceKm: distanceKm
        )
    }
}
