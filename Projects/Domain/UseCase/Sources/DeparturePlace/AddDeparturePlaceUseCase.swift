//
//  AddDeparturePlaceUseCase.swift
//  UseCase
//

import Entity

public protocol AddDeparturePlaceUseCase: Sendable {
    func execute(
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double,
        isDefault: Bool
    ) async throws -> DeparturePlace
}
