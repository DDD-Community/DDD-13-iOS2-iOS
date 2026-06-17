//
//  DeparturePlaceClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

@DependencyClient
public struct DeparturePlaceClient: Sendable {
    public var fetchDeparturePlaces: @Sendable () async throws -> [DeparturePlace]
    public var updateDeparturePlace: @Sendable (
        _ id: Int64,
        _ label: String,
        _ address: String,
        _ roadAddress: String,
        _ placeName: String,
        _ latitude: Double,
        _ longitude: Double
    ) async throws -> DeparturePlace
    public var addDeparturePlace: @Sendable (
        _ label: String,
        _ address: String,
        _ roadAddress: String,
        _ placeName: String,
        _ latitude: Double,
        _ longitude: Double,
        _ isDefault: Bool
    ) async throws -> DeparturePlace
    public var deleteDeparturePlace: @Sendable (_ id: Int64) async throws -> Void
    public var setDefaultDeparturePlace: @Sendable (_ id: Int64) async throws -> DeparturePlace
}

public extension DeparturePlaceClient {
    static func live(
        fetchUseCase: any FetchDeparturePlacesUseCase,
        updateUseCase: any UpdateDeparturePlaceUseCase,
        addUseCase: any AddDeparturePlaceUseCase,
        deleteUseCase: any DeleteDeparturePlaceUseCase,
        setDefaultUseCase: any SetDefaultDeparturePlaceUseCase
    ) -> Self {
        Self(
            fetchDeparturePlaces: { try await fetchUseCase.execute() },
            updateDeparturePlace: { id, label, address, roadAddress, placeName, latitude, longitude in
                try await updateUseCase.execute(
                    id: id,
                    label: label,
                    address: address,
                    roadAddress: roadAddress,
                    placeName: placeName,
                    latitude: latitude,
                    longitude: longitude
                )
            },
            addDeparturePlace: { label, address, roadAddress, placeName, latitude, longitude, isDefault in
                try await addUseCase.execute(
                    label: label,
                    address: address,
                    roadAddress: roadAddress,
                    placeName: placeName,
                    latitude: latitude,
                    longitude: longitude,
                    isDefault: isDefault
                )
            },
            deleteDeparturePlace: { id in try await deleteUseCase.execute(id: id) },
            setDefaultDeparturePlace: { id in try await setDefaultUseCase.execute(id: id) }
        )
    }
}

extension DeparturePlaceClient: DependencyKey {
    public static var liveValue: DeparturePlaceClient {
        DeparturePlaceClient(
            fetchDeparturePlaces: { throw DeparturePlaceClientError.notImplemented },
            updateDeparturePlace: { _, _, _, _, _, _, _ in throw DeparturePlaceClientError.notImplemented },
            addDeparturePlace: { _, _, _, _, _, _, _ in throw DeparturePlaceClientError.notImplemented },
            deleteDeparturePlace: { _ in throw DeparturePlaceClientError.notImplemented },
            setDefaultDeparturePlace: { _ in throw DeparturePlaceClientError.notImplemented }
        )
    }

    public static let testValue: DeparturePlaceClient = DeparturePlaceClient()
}

public extension DependencyValues {
    var departurePlaceClient: DeparturePlaceClient {
        get { self[DeparturePlaceClient.self] }
        set { self[DeparturePlaceClient.self] = newValue }
    }
}
