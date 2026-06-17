//
//  SetDefaultDeparturePlaceUseCase.swift
//  UseCase
//

import Entity

public protocol SetDefaultDeparturePlaceUseCase: Sendable {
    func execute(id: Int64) async throws -> DeparturePlace
}
