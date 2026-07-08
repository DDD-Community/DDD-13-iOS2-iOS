//
//  FetchPlaceDetailsUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchPlaceDetailsUseCaseImpl: FetchPlaceDetailsUseCase {
    private let repository: PlaceDetailsRepositoryProtocol

    public init(repository: PlaceDetailsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(ids: [Int]) async throws -> [PlaceDetail] {
        try await repository.fetchPlaceDetails(ids: ids)
    }
}
