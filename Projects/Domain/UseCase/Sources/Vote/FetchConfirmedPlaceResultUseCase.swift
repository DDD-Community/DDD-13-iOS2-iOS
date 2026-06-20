//
//  FetchConfirmedPlaceResultUseCase.swift
//  UseCase
//

import Entity

public protocol FetchConfirmedPlaceResultUseCase: Sendable {
    func execute(meetingId: Int) async throws -> ConfirmedPlaceResult
}
