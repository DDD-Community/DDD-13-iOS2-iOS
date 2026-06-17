//
//  UpdateDeparturePlaceUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class UpdateDeparturePlaceUseCaseImpl: UpdateDeparturePlaceUseCase {
    private let repository: DeparturePlaceRepositoryProtocol

    public init(repository: DeparturePlaceRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        id: Int64,
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double
    ) async throws -> DeparturePlace {
        try await repository.updateDeparturePlace(
            id: id,
            label: label,
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude
        )
    }
}
