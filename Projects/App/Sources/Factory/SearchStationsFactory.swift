//
//  SearchStationsFactory.swift
//  App
//
//  Repository → UseCase → TCA Client을 조립하는 Composition Root
//

import CoreDependencies
import DataUseCase
import Repository

enum SearchStationsFactory {
    static func makeClient() -> SearchStationsClient {
        let repository = LocationSearchRepositoryImpl()
        let useCase = SearchStationsUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
