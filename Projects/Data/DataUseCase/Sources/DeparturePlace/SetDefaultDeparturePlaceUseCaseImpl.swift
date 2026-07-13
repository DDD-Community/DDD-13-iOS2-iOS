//
//  SetDefaultDeparturePlaceUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class SetDefaultDeparturePlaceUseCaseImpl: SetDefaultDeparturePlaceUseCase {
    private let repository: DeparturePlaceRepositoryProtocol

    public init(repository: DeparturePlaceRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: Int) async throws -> DeparturePlace {
        try await repository.setDefaultDeparturePlace(id: id)
    }
}
