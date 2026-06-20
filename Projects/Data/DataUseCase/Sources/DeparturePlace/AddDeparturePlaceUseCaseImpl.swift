//
//  AddDeparturePlaceUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class AddDeparturePlaceUseCaseImpl: AddDeparturePlaceUseCase {
    private let repository: DeparturePlaceRepositoryProtocol

    public init(repository: DeparturePlaceRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double,
        isDefault: Bool
    ) async throws -> DeparturePlace {
        try await repository.addDeparturePlace(
            label: label,
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude,
            isDefault: isDefault
        )
    }
}
