//
//  MidpointStationRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Model
import Networking

public final class MidpointStationRepositoryImpl: MidpointStationRepositoryProtocol {
    public init() {}

    public func fetchMidpointStations(meetingId: Int) async throws -> [MidpointStation] {
        let response: MidpointStationsResponseDTO = try await NetworkManager.shared.request(
            MidpointStationEndpoint.fetch(meetingId: meetingId)
        )

        return response.candidates.map { $0.toEntity() }
    }
}
