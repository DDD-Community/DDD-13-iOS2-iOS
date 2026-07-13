//
//  FetchPlaceVoteUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchPlaceVoteUseCaseImpl: FetchPlaceVoteUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int) async throws -> PlaceVote {
        try await repository.fetchPlaceVote(meetingId: meetingId)
    }
}
