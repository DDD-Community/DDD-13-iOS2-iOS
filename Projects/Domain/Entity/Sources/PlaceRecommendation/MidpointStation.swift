//
//  MidpointStation.swift
//  Entity
//

import Foundation

// TODO: 서버 응답에 stationId 추가 예정. 현재 midpoint-stations 응답에 없어 -1 임시 매핑됨.
public struct MidpointStation: Equatable, Sendable, Identifiable {
    public let stationId: Int
    public let rank: Int
    public let stationName: String
    public let lines: String
    public let distanceKm: Double

    public var id: Int { rank }

    public init(
        stationId: Int,
        rank: Int,
        stationName: String,
        lines: String,
        distanceKm: Double
    ) {
        self.stationId = stationId
        self.rank = rank
        self.stationName = stationName
        self.lines = lines
        self.distanceKm = distanceKm
    }
}
