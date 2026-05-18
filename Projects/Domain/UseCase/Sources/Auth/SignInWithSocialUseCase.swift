//
//  SignInWithSocialUseCase.swift
//  UseCase
//

import Entity

public protocol SignInWithSocialUseCase: Sendable {
    func execute(provider: SocialAuthProvider) async throws -> LoginResult
}
