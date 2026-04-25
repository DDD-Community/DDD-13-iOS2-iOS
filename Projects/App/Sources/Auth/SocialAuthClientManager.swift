//
//  SocialAuthClientManager.swift
//  Bangawo
//
//  Created by DDD-iOS2 on 4/25/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import KakaoSDKUser
import KakaoSDKAuth
import DomainInterface
import Entity
import Presentation
import Utill

extension SocialAuthClient {
    /// 앱에서 실제로 사용하는 소셜 로그인 구현체입니다.
    ///
    /// `Presentation` 모듈의 `LoginFeature`는 카카오/애플/네이버 SDK를 직접 알지 않고,
    /// `SocialAuthClientManager.login(provider)` 인터페이스만 호출합니다.
    /// 실제 SDK 호출은 앱 타겟에 있는 이 live 구현에서 담당합니다.
    static let live = SocialAuthClient { provider in
        switch provider {
        case .kakao:
            // 카카오 로그인은 Kakao SDK가 필요하므로 App 모듈의 Manager에서 처리합니다.
            return try await SocialAuthClientManager().kakaoLogin()

        case .apple:
            // TODO: Apple 로그인 SDK/AuthenticationServices 연동 시 구현합니다.
            throw SocialAuthClientError.notImplemented(.apple)

        case .naver:
            // TODO: Naver 로그인 SDK 연동 시 구현합니다.
            throw SocialAuthClientError.notImplemented(.naver)
        }
    }
}

private struct SocialAuthClientManager {
    /// SNS 로그인을 수행하고, 발급받은 OAuth 토큰을 앱 공통 모델인 `SocialAuthToken`으로 변환합니다.
    ///
    /// 현재는 Kakao SDK의 `loginWithKakaoTalk`는 내부에서 `UIApplication.openURL`을 호출합니다.
    /// `UIApplication` API는 반드시 메인 스레드에서 호출되어야 하므로 `@MainActor`가 필요합니다.
    /// TCA의 `.run` effect는 백그라운드 executor에서 실행될 수 있기 때문에, 이 격리가 없으면
    /// `UIApplication.openURL: must be used from main thread only` 런타임 경고가 발생할 수 있습니다.
    @MainActor
    func kakaoLogin() async throws -> SocialAuthToken {
        // Kakao SDK는 completion 기반 API를 제공하므로,
        // TCA Effect에서 사용하기 편하도록 async/await 형태로 감싸줍니다.
        try await withCheckedThrowingContinuation { continuation in
            // 카카오톡 로그인과 카카오계정 로그인 모두 동일한 결과 타입을 반환하므로
            // 공통 completion을 만들어 두고 아래 분기에서 재사용합니다.
            let completion: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error {
                    Log.debug("❌ 카카오 로그인 에러 - ")
                    print(error.localizedDescription)
                    // SDK 에러 타입을 Presentation에서 정의한 공통 에러 타입으로 변환합니다.
                    continuation.resume(throwing: SocialAuthClientError.underlying(error.localizedDescription))
                    return
                }

                guard let oauthToken else {
                    // 에러는 없지만 토큰도 없는 비정상 케이스를 방어합니다.
                    continuation.resume(throwing: SocialAuthClientError.missingToken(.kakao))
                    return
                }
                Log.debug("✅ 카카오 로그인 성공")
                continuation.resume(
                    returning: SocialAuthToken(
                        // 우리 서버 소셜 로그인 API에서 주로 사용할 토큰입니다.
                        accessToken: oauthToken.accessToken,
                        // 필요 시 토큰 갱신 흐름에서 사용할 수 있도록 함께 전달합니다.
                        refreshToken: oauthToken.refreshToken,
                        // OIDC 설정을 사용하는 경우 서버 검증에 활용할 수 있습니다.
                        idToken: oauthToken.idToken
                    )
                )
            }

            // 기기에 카카오톡이 설치되어 있고 URL Scheme 조회가 가능하면 카카오톡 앱 로그인으로 진행합니다.
            // `LSApplicationQueriesSchemes`에 `kakaokompassauth`, `kakaolink`가 없으면
            // 앱이 설치되어 있어도 false가 나올 수 있습니다.
            if UserApi.isKakaoTalkLoginAvailable() {
                Log.debug("✅ 카카오톡으로 로그인 하기")
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                // 카카오톡 앱 로그인이 불가능한 경우 Safari/AuthSession 기반의 카카오계정 로그인으로 fallback합니다.
                Log.debug("✅ 카카오 계정으로 로그인 하기")
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}
