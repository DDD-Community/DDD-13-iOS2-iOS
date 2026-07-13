//
//  NearbyPlacesFactory.swift
//  App
//
//  Repository → UseCase → TCA Client을 조립하는 Composition Root
//

import CoreDependencies
import DataUseCase
import Repository

enum NearbyPlacesFactory {
    static func makeClient() -> NearbyPlacesClient {
        let repository = NearbyPlacesRepositoryImpl()
        let useCase = FetchNearbyPlacesUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
