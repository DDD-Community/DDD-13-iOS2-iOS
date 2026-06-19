//
//  SubmitDateVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class SubmitDateVoteUseCaseImpl: SubmitDateVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, optionIds: [Int]) async throws {
        try await repository.submitDateVote(meetingId: meetingId, optionIds: optionIds)
    }
}
