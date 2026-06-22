//
//  PlacePickRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Model
import Networking

public final class PlacePickRepositoryImpl: PlacePickRepositoryProtocol {
    public init() {}

    public func pickPlace(meetingId: Int, placeId: Int) async throws {
        try await NetworkManager.shared.requestVoid(
            PlacePickEndpoint.pick(meetingId: meetingId, placeId: placeId)
        )
    }

    public func unpickPlace(meetingId: Int, placeId: Int) async throws {
        try await NetworkManager.shared.requestVoid(
            PlacePickEndpoint.unpick(meetingId: meetingId, placeId: placeId)
        )
    }

    public func fetchPickStatus(meetingId: Int) async throws -> PlacePickStatus {
        let response: PlacePickStatusResponseDTO = try await NetworkManager.shared.request(
            PlacePickEndpoint.fetchStatus(meetingId: meetingId)
        )

        return response.toEntity()
    }
}
