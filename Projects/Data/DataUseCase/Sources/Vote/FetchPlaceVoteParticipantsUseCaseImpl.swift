//
//  FetchPlaceVoteParticipantsUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchPlaceVoteParticipantsUseCaseImpl: FetchPlaceVoteParticipantsUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int) async throws -> [PlaceVoteParticipant] {
        try await repository.fetchPlaceVoteParticipants(meetingId: meetingId)
    }
}
