//
//  PlaceDetailsFactory.swift
//  App
//
//  Repository → UseCase → TCA Client을 조립하는 Composition Root
//

import CoreDependencies
import DataUseCase
import Repository

enum PlaceDetailsFactory {
    static func makeClient() -> PlaceDetailsClient {
        let repository = PlaceDetailsRepositoryImpl()
        let useCase = FetchPlaceDetailsUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
