//
//  UpdateDeparturePlaceUseCase.swift
//  UseCase
//

import Entity

public protocol UpdateDeparturePlaceUseCase: Sendable {
    func execute(
        id: Int,
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double
    ) async throws -> DeparturePlace
}
