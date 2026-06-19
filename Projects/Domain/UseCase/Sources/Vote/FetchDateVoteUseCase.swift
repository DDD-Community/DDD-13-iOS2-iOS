//
//  FetchDateVoteUseCase.swift
//  UseCase
//

import Entity

public protocol FetchDateVoteUseCase: Sendable {
    func execute(meetingId: Int) async throws -> DateVote
}
