//
//  FetchDeparturePlacesUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchDeparturePlacesUseCaseImpl: FetchDeparturePlacesUseCase {
    private let repository: DeparturePlaceRepositoryProtocol

    public init(repository: DeparturePlaceRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [DeparturePlace] {
        try await repository.fetchDeparturePlaces()
    }
}
