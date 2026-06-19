//
//  FetchDateVoteUseCase.swift
//  UseCase
//

import Entity

public protocol FetchDateVoteUseCase: Sendable {
    func execute(meetingId: Int64) async throws -> DateVote
}
