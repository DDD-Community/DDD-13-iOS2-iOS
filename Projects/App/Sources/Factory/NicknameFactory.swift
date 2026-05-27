//
//  NicknameFactory.swift
//  Bangawo
//
//

import CoreDependencies
import DataUseCase
import Repository

enum NicknameFactory {
    static func makeClient() -> NicknameClient {
        let repository = AuthRepositoryImpl()
        let useCase = ValidateNicknameUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
