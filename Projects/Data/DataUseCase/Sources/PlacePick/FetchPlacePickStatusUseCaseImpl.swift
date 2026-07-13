//
//  FetchPlacePickStatusUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchPlacePickStatusUseCaseImpl: FetchPlacePickStatusUseCase {
    private let repository: PlacePickRepositoryProtocol

    public init(repository: PlacePickRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int) async throws -> PlacePickStatus {
        try await repository.fetchPickStatus(meetingId: meetingId)
    }
}
