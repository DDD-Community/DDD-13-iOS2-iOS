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
    
    public func execute(nickname: String, agreedTermsIds: [Int], departureLabel: String, departureAddress: String, latitude: Double, longitude: Double) async throws -> RegisterMemberResult {
        return try await repository.registerMember(nickname: nickname, agreedTermsIds: agreedTermsIds, departureLabel: departureLabel, departureAddress: departureAddress, latitude: latitude, longitude: longitude)
    }
}
