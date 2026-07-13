//
//  StartDateVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class StartDateVoteUseCaseImpl: StartDateVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, candidateDates: [String], durationDays: Int) async throws {
        try await repository.startDateVote(
            meetingId: meetingId,
            candidateDates: candidateDates,
            durationDays: durationDays
        )
    }
}
