//
//  PlacePickRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol PlacePickRepositoryProtocol: Sendable {
    func pickPlace(meetingId: Int, placeId: Int) async throws
    func unpickPlace(meetingId: Int, placeId: Int) async throws
    func fetchPickStatus(meetingId: Int) async throws -> PlacePickStatus
}
