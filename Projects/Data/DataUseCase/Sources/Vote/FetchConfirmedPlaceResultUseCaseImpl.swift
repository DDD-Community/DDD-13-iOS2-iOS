//
//  FetchConfirmedPlaceResultUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchConfirmedPlaceResultUseCaseImpl: FetchConfirmedPlaceResultUseCase {
    private let repository: VoteRepositoryProtocol

    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int) async throws -> ConfirmedPlaceResult {
        try await repository.fetchConfirmedPlaceResult(meetingId: meetingId)
    }
}
