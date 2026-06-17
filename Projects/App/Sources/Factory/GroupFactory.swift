//
//  GroupFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum GroupFactory {
    static func makeClient() -> GroupClient {
        let repository = GroupRepositoryImpl()
        let fetchUseCase = FetchGroupsUseCaseImpl(repository: repository)
        let createUseCase = CreateGroupUseCaseImpl(repository: repository)
        let fetchDetailUseCase = FetchGroupDetailUseCaseImpl(repository: repository)
        let updateAttendanceUseCase = UpdateAttendanceUseCaseImpl(repository: repository)
        return .live(
            fetchUseCase: fetchUseCase,
            createUseCase: createUseCase,
            fetchDetailUseCase: fetchDetailUseCase,
            updateAttendanceUseCase: updateAttendanceUseCase
        )
    }
}
