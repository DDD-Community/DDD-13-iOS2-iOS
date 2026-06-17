//
//  DeparturePlaceRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol DeparturePlaceRepositoryProtocol: Sendable {
    func fetchDeparturePlaces() async throws -> [DeparturePlace]
    func updateDeparturePlace(
        id: Int64,
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double
    ) async throws -> DeparturePlace
    func addDeparturePlace(
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double,
        isDefault: Bool
    ) async throws -> DeparturePlace
    func deleteDeparturePlace(id: Int64) async throws
    func setDefaultDeparturePlace(id: Int64) async throws -> DeparturePlace
}
