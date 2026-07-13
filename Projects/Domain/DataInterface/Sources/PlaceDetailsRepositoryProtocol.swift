//
//  PlaceDetailsRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol PlaceDetailsRepositoryProtocol: Sendable {
    func fetchPlaceDetails(ids: [Int]) async throws -> [PlaceDetail]
}
