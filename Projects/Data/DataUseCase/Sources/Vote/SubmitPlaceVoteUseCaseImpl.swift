//
//  SubmitPlaceVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class SubmitPlaceVoteUseCaseImpl: SubmitPlaceVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, placeIds: [Int]) async throws {
        try await repository.submitPlaceVote(meetingId: meetingId, placeIds: placeIds)
    }
}
