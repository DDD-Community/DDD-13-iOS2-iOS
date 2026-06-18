//
//  SignupTermsUseCase.swift
//  UseCase
//

import Entity

public protocol SignupTermsUseCase: Sendable {
    func execute() async throws -> [SignupTerm]
}
