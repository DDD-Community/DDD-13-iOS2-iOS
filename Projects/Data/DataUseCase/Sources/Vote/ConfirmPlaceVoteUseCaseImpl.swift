//
//  ConfirmPlaceVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class ConfirmPlaceVoteUseCaseImpl: ConfirmPlaceVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int) async throws {
        try await repository.confirmPlaceVote(meetingId: meetingId)
    }
}
