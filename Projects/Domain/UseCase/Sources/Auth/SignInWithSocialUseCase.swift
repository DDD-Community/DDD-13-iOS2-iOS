//
//  SignInWithSocialUseCase.swift
//  UseCase
//
//  Created by DDD-iOS2 on 5/4/26.
//

import Entity

public protocol SignInWithSocialUseCase: Sendable {
    func execute(provider: SocialAuthProvider) async throws -> LoginResult
}
