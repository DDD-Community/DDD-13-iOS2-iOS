//
//  SignInWithSocialUseCaseImpl.swift
//  DataUseCase
//
//  Created by DDD-iOS2 on 5/4/26.
//

import DataInterface
import DomainInterface
import Entity
import Service
import Utill
import UseCase

public final class SignInWithSocialUseCaseImpl: SignInWithSocialUseCase {
    private let repository: AuthRepositoryProtocol
    private let kakaoLoginService: KakaoLoginServiceInterface

    public init(
        repository: AuthRepositoryProtocol,
        kakaoLoginService: KakaoLoginServiceInterface
    ) {
        self.repository = repository
        self.kakaoLoginService = kakaoLoginService
    }

    public func execute(provider: SocialAuthProvider) async throws -> AuthToken {
        switch provider {
        case .kakao:
            let socialToken = try await kakaoLoginService.login()
            return try await signInWithServer(
                provider: provider,
                providerToken: socialToken.accessToken
            )

        case .apple, .naver:
            throw SocialAuthClientError.notImplemented(provider)
        }
    }
}

private extension SignInWithSocialUseCaseImpl {
    func signInWithServer(provider: SocialAuthProvider, providerToken: String) async throws -> AuthToken {
        let response = try await repository.login(
            provider: provider.serverValue,
            providerToken: providerToken
        )

        KeyChainManager.addItem(key: KeyChainKey.accessToken, value: response.accessToken)
        KeyChainManager.addItem(key: KeyChainKey.refreshToken, value: response.refreshToken)

        return AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            isNewMember: response.isNewMember,
            registrationCompleted: response.registrationCompleted
        )
    }
}
