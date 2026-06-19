//
//  ConfirmDateVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class ConfirmDateVoteUseCaseImpl: ConfirmDateVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, optionId: Int) async throws {
        try await repository.confirmDateVote(meetingId: meetingId, optionId: optionId)
    }
}
