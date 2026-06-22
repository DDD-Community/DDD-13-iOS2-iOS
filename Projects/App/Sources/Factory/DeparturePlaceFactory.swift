//
//  DeparturePlaceFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum DeparturePlaceFactory {
    static func makeClient() -> DeparturePlaceClient {
        let repository = DeparturePlaceRepositoryImpl()
        let fetchUseCase = FetchDeparturePlacesUseCaseImpl(repository: repository)
        let updateUseCase = UpdateDeparturePlaceUseCaseImpl(repository: repository)
        let addUseCase = AddDeparturePlaceUseCaseImpl(repository: repository)
        let deleteUseCase = DeleteDeparturePlaceUseCaseImpl(repository: repository)
        let setDefaultUseCase = SetDefaultDeparturePlaceUseCaseImpl(repository: repository)
        return .live(
            fetchUseCase: fetchUseCase,
            updateUseCase: updateUseCase,
            addUseCase: addUseCase,
            deleteUseCase: deleteUseCase,
            setDefaultUseCase: setDefaultUseCase
        )
    }
}
