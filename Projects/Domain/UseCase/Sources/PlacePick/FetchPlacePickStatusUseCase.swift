//
//  FetchPlacePickStatusUseCase.swift
//  UseCase
//

import Entity

public protocol FetchPlacePickStatusUseCase: Sendable {
    func execute(meetingId: Int) async throws -> PlacePickStatus
}
