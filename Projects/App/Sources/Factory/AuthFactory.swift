//
//  AuthFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository
import Service

enum AuthFactory {
    static func makeClient() -> SocialAuthClient {
        let repository = AuthRepositoryImpl()
        let useCase = SignInWithSocialUseCaseImpl(
            repository: repository,
            kakaoLoginService: KakaoLoginService(),
            naverLoginService: NaverLoginService(),
            appleLoginService: AppleLoginService()
        )

        return .live(useCase: useCase)
    }
}
