//
//  SetDefaultDeparturePlaceUseCase.swift
//  UseCase
//

import Entity

public protocol SetDefaultDeparturePlaceUseCase: Sendable {
    func execute(id: Int) async throws -> DeparturePlace
}
