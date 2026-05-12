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

    public func execute(provider: SocialAuthProvider) async throws -> LoginResult {
        switch provider {
        case .kakao:
            let socialToken = try await kakaoLoginService.login() // 소셜인증 후
            return try await signInWithServer( // 서버 로그인 요청
                provider: provider,
                providerToken: socialToken.accessToken
            )

        case .apple, .naver: // TODO: 구현 필요
            throw SocialAuthClientError.notImplemented(provider)
        }
    }
}

private extension SignInWithSocialUseCaseImpl {
    func signInWithServer(provider: SocialAuthProvider, providerToken: String) async throws -> LoginResult { // 서버 로그인 요청
        let loginResult = try await repository.login(
            provider: provider.serverValue,
            providerToken: providerToken
        )

        repository.saveAuthTokens(loginResult.tokens)

        return loginResult
    }
}
