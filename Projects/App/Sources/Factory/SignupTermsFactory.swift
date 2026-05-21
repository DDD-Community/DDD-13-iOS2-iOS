//
//  SignupTermsFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum SignupTermsFactory {
    static func makeClient() -> SignupTermsClient {
        let repository = SignupTermsRepositoryImpl()
        let useCase = SignupTermsUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
