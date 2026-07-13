//
//  FetchDateVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchDateVoteUseCaseImpl: FetchDateVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int) async throws -> DateVote {
        try await repository.fetchDateVote(meetingId: meetingId)
    }
}
