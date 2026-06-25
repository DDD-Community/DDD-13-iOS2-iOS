//
//  FetchPlaceVoteTravelBurdenUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchPlaceVoteTravelBurdenUseCaseImpl: FetchPlaceVoteTravelBurdenUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, placeId: Int) async throws -> PlaceVoteTravelBurden {
        try await repository.fetchPlaceVoteTravelBurden(meetingId: meetingId, placeId: placeId)
    }
}
