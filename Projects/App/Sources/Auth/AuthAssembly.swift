//
//  AuthAssembly.swift
//  Bangawo
//
//  Created by DDD-iOS2 on 5/5/26.
//

import CoreDependencies
import DataUseCase
import Repository
import Service

enum AuthAssembly {
    static func makeSocialAuthClient() -> SocialAuthClient {
        let repository = AuthRepository()
        let useCase = SignInWithSocialUseCaseImpl(
            repository: repository,
            kakaoLoginService: KakaoLoginService()
        )

        return .live(useCase: useCase)
    }
}
