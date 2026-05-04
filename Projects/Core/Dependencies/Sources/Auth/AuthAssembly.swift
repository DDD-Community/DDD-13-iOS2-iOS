//
//  AuthAssembly.swift
//  CoreDependencies
//
//  Created by DDD-iOS2 on 5/4/26.
//

import DataUseCase
import Repository
import Service

enum AuthAssembly { // 단순 조립 함수
    static func makeSocialAuthClient() -> SocialAuthClient {
        let repository = AuthRepository()
        let useCase = SignInWithSocialUseCaseImpl(
            repository: repository,
            kakaoLoginService: KakaoLoginService()
        )

        return .live(useCase: useCase)
    }
}
