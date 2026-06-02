//
//  AuthFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository
import Service

enum AuthFactory {
    static func makeSocialAuthClient() -> SocialAuthClient {
        let repository = AuthRepositoryImpl()
        let useCase = SignInWithSocialUseCaseImpl(
            repository: repository,
            kakaoLoginService: KakaoLoginService(),
            naverLoginService: NaverLoginService(),
            appleLoginService: AppleLoginService()
        )

        return .live(useCase: useCase)
    }

    static func makeNicknameClient() -> NicknameClient {
        let repository = AuthRepositoryImpl()
        let useCase = ValidateNicknameUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }

    static func makeRegisterMemberClient() -> RegisterMemberClient {
        let repository = AuthRepositoryImpl()
        let useCase = RegisterMemberUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }

    static func makeSignupTermsClient() -> SignupTermsClient {
        let repository = SignupTermsRepositoryImpl()
        let useCase = SignupTermsUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
