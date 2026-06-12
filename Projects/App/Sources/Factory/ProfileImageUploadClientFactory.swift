//
//  ProfileImageUploadClientFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum ProfileImageUploadClientFactory {
    static func makeClient() -> ProfileImageUploadClient {
        let repository = StorageRepositoryImpl()
        let useCase = UploadProfileImageUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
