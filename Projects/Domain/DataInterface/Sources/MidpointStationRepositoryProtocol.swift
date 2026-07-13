//
//  MidpointStationRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol MidpointStationRepositoryProtocol: Sendable {
    func fetchMidpointStations(meetingId: Int) async throws -> [MidpointStation]
}
