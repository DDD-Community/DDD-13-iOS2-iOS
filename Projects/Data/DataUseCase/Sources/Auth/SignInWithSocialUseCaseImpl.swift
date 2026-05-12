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
import Utill

public final class SignInWithSocialUseCaseImpl: SignInWithSocialUseCase {
    private let repository: AuthRepositoryProtocol
    private let kakaoLoginService: KakaoLoginServiceInterface
    private let naverLoginService: NaverLoginServiceInterface

    public init(
        repository: AuthRepositoryProtocol,
        kakaoLoginService: KakaoLoginServiceInterface,
        naverLoginService: NaverLoginServiceInterface
    ) {
        self.repository = repository
        self.kakaoLoginService = kakaoLoginService
        self.naverLoginService = naverLoginService
    }

    public func execute(provider: SocialAuthProvider) async throws -> LoginResult {
        switch provider {
        case .kakao:
            let socialToken = try await kakaoLoginService.login() // 소셜인증 후
            Log.debug("🔑 kakaoSocialToken: \(socialToken)")
            return try await signInWithServer( // 서버 로그인 요청
                provider: provider,
                providerToken: socialToken.accessToken
            )

        case .naver:
            let socialToken = try await naverLoginService.login()
            Log.debug("🔑 naverSocialToken: \(socialToken)")
            return try await signInWithServer(
                provider: provider,
                providerToken: socialToken.accessToken
            )

        case .apple: // TODO: 구현 필요
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
        // 직접 키체인에 접근하는 것이 아닌 repository를 통해 접근하도록
        repository.saveAuthTokens(loginResult.tokens)

        return loginResult
    }
}
