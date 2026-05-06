//
//  AuthFactory.swift
//  Bangawo
//
//  Created by DDD-iOS2 on 5/5/26.
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
            naverLoginService: NaverLoginService()
        )

        return .live(useCase: useCase)
    }
}
