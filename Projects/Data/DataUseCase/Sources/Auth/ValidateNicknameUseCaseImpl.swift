//
//  ValidateNicknameUseCaseImpl.swift
//  DataUseCase
//
//

import DataInterface
import DomainInterface
import UseCase

public final class ValidateNicknameUseCaseImpl: ValidateNicknameUseCase {
    private let repository: AuthRepositoryProtocol

    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(nickname: String) async throws {
        try await repository.validateNickname(nickname)
    }
}
