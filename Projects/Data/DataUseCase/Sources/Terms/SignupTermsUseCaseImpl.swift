//
//  SignupTermsUseCaseImpl.swift
//  DataUseCase
//
import UseCase
import Entity
import DataInterface

public final class SignupTermsUseCaseImpl: SignupTermsUseCase {
    private let repository: SignupTermsRepositoryProtocol
    
    public init(repository: SignupTermsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> [SignupTerm] {
        try await repository.fetchSignupTerms()
    }
}
