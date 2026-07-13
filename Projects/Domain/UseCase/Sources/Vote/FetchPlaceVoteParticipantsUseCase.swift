//
//  FetchPlaceVoteParticipantsUseCase.swift
//  UseCase
//

import Entity

public protocol FetchPlaceVoteParticipantsUseCase: Sendable {
    func execute(meetingId: Int) async throws -> [PlaceVoteParticipant]
}
