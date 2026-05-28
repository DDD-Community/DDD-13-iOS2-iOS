//
//  SignInWithSocialUseCaseImpl.swift
//  DataUseCase
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
    private let appleLoginService: AppleLoginServiceInterface

    public init(
        repository: AuthRepositoryProtocol,
        kakaoLoginService: KakaoLoginServiceInterface,
        naverLoginService: NaverLoginServiceInterface,
        appleLoginService: AppleLoginServiceInterface,
    ) {
        self.repository = repository
        self.kakaoLoginService = kakaoLoginService
        self.naverLoginService = naverLoginService
        self.appleLoginService = appleLoginService
    }

    public func execute(provider: SocialAuthProvider) async throws -> LoginResult {
        switch provider {
        case .kakao:
            let socialAuthResult = try await kakaoLoginService.login() // 소셜인증 후
            return try await signInWithServer( // 서버 로그인 요청
                provider: provider,
                providerToken: socialAuthResult.token.accessToken,
                suggestedName: socialAuthResult.suggestedName
            )

        case .naver:
            let socialAuthResult = try await naverLoginService.login()
            return try await signInWithServer(
                provider: provider,
                providerToken: socialAuthResult.token.accessToken,
                suggestedName: socialAuthResult.suggestedName
            )

        case .apple:
            let socialAuthResult = try await appleLoginService.login()
            return try await signInWithServer(
                provider: provider,
                providerToken: socialAuthResult.token.accessToken,
                suggestedName: socialAuthResult.suggestedName
            )
        }
    }
}

private extension SignInWithSocialUseCaseImpl {
    func signInWithServer(
        provider: SocialAuthProvider,
        providerToken: String,
        suggestedName: String?
    ) async throws -> LoginResult { // 서버 로그인 요청
        let loginResult = try await repository.login(
            provider: provider.serverValue,
            providerToken: providerToken
        )
        // 직접 키체인에 접근하는 것이 아닌 repository를 통해 접근하도록
        repository.saveAuthTokens(loginResult.tokens)

        return LoginResult(
            tokens: loginResult.tokens,
            firstSocialLogin: loginResult.firstSocialLogin,
            registrationCompleted: loginResult.registrationCompleted,
            suggestedName: suggestedName
        )
    }
}
