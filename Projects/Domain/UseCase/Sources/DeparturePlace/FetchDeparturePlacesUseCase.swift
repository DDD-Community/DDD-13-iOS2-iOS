//
//  FetchDeparturePlacesUseCase.swift
//  UseCase
//

import Entity

public protocol FetchDeparturePlacesUseCase: Sendable {
    func execute() async throws -> [DeparturePlace]
}
