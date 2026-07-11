//
//  PlaceOptionsFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum PlaceOptionsFactory {
    static func makeClient() -> PlaceOptionsClient {
        let repository = PlaceOptionsRepositoryImpl()
        let useCase = FetchPlaceVibesUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
