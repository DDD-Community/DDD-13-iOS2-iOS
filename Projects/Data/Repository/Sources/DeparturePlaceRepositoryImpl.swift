//
//  DeparturePlaceRepositoryImpl.swift
//  Repository
//

import DataInterface
import Entity
import Model
import API
import Networking

public final class DeparturePlaceRepositoryImpl: DeparturePlaceRepositoryProtocol {
    public init() {}

    public func fetchDeparturePlaces() async throws -> [DeparturePlace] {
        let response: [DeparturePlaceResponseDTO] = try await NetworkManager.shared.request(
            DeparturePlaceEndpoint.fetchDeparturePlaces
        )
        return response.map { $0.toEntity() }
    }

    public func updateDeparturePlace(
        id: Int64,
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double
    ) async throws -> DeparturePlace {
        let requestDTO = UpdateDeparturePlaceRequestDTO(
            label: label,
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude
        )
        let response: DeparturePlaceResponseDTO = try await NetworkManager.shared.request(
            DeparturePlaceEndpoint.updateDeparturePlace(id: id, requestDTO)
        )
        return response.toEntity()
    }

    public func addDeparturePlace(
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double,
        isDefault: Bool
    ) async throws -> DeparturePlace {
        let requestDTO = AddDeparturePlaceRequestDTO(
            label: label,
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude,
            isDefault: isDefault
        )
        let response: DeparturePlaceResponseDTO = try await NetworkManager.shared.request(
            DeparturePlaceEndpoint.addDeparturePlace(requestDTO)
        )
        return response.toEntity()
    }

    public func deleteDeparturePlace(id: Int64) async throws {
        try await NetworkManager.shared.requestVoid(
            DeparturePlaceEndpoint.deleteDeparturePlace(id: id)
        )
    }

    public func setDefaultDeparturePlace(id: Int64) async throws -> DeparturePlace {
        let response: DeparturePlaceResponseDTO = try await NetworkManager.shared.request(
            DeparturePlaceEndpoint.setDefaultDeparturePlace(id: id)
        )
        return response.toEntity()
    }
}
