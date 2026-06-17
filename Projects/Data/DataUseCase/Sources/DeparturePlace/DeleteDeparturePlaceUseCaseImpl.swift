//
//  DeleteDeparturePlaceUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class DeleteDeparturePlaceUseCaseImpl: DeleteDeparturePlaceUseCase {
    private let repository: DeparturePlaceRepositoryProtocol

    public init(repository: DeparturePlaceRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: Int64) async throws {
        try await repository.deleteDeparturePlace(id: id)
    }
}
