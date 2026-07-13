//
//  StartPlaceVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class StartPlaceVoteUseCaseImpl: StartPlaceVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, durationDays: Int) async throws {
        try await repository.startPlaceVote(meetingId: meetingId, durationDays: durationDays)
    }
}
