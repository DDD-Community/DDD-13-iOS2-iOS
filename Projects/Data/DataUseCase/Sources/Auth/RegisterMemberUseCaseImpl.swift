//
//  RegisterMemberUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import DomainInterface
import Entity
import UseCase

public final class RegisterMemberUseCaseImpl: RegisterMemberUseCase {
    private let repository: AuthRepositoryProtocol
    
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(_ member: RegisterMember) async throws -> RegisterMemberResult {
        return try await repository.registerMember(member)
    }
}
