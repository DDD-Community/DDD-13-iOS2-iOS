//
//  FetchPlaceVibesUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class FetchPlaceVibesUseCaseImpl: FetchPlaceVibesUseCase {
    private let repository: PlaceOptionsRepositoryProtocol

    public init(repository: PlaceOptionsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [String] {
        try await repository.fetchVibes()
    }
}
