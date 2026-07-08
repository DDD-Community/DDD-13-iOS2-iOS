//
//  FetchPlaceDetailsUseCase.swift
//  UseCase
//

import Entity

public protocol FetchPlaceDetailsUseCase: Sendable {
    func execute(ids: [Int]) async throws -> [PlaceDetail]
}
