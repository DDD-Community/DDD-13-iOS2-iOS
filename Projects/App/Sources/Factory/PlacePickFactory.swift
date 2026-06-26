//
//  PlacePickFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum PlacePickFactory {
    static func makeClient() -> PlacePickClient {
        let repository = PlacePickRepositoryImpl()
        let toggleUseCase = TogglePlacePickUseCaseImpl(repository: repository)
        let fetchUseCase = FetchPlacePickStatusUseCaseImpl(repository: repository)
        return .live(toggleUseCase: toggleUseCase, fetchUseCase: fetchUseCase)
    }
}
