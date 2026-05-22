//
//  KakaoLoginService.swift
//  Service
//

import KakaoSDKAuth
import KakaoSDKUser

import DomainInterface
import Entity
import Utill

public protocol KakaoLoginServiceInterface: Sendable {
    @MainActor
    func login() async throws -> SocialAuthToken
}

public final class KakaoLoginService: KakaoLoginServiceInterface {
    public init() {}

    @MainActor
    public func login() async throws -> SocialAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error {
                    Log.debug("❌ 카카오 로그인 실패: \(error.localizedDescription)")
                    continuation.resume(throwing: SocialAuthClientError.underlying(error.localizedDescription))
                    return
                }

                guard let oauthToken else {
                    continuation.resume(throwing: SocialAuthClientError.missingToken(.kakao))
                    return
                }

                Log.debug("✅ 카카오 로그인 성공")
                continuation.resume(
                    returning: SocialAuthToken(
                        accessToken: oauthToken.accessToken,
                        refreshToken: oauthToken.refreshToken,
                        idToken: oauthToken.idToken
                    )
                )
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                Log.debug("✅ 카카오톡으로 로그인")
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                Log.debug("✅ 카카오 계정으로 로그인")
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}
