//
//  FetchPlaceVoteUseCase.swift
//  UseCase
//

import Entity

public protocol FetchPlaceVoteUseCase: Sendable {
    func execute(meetingId: Int) async throws -> PlaceVote
}
