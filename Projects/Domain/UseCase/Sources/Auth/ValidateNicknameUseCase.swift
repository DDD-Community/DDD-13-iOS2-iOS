//
//  ValidateNicknameUseCase.swift
//  UseCase
//
//

public protocol ValidateNicknameUseCase: Sendable {
    func execute(nickname: String) async throws
}
