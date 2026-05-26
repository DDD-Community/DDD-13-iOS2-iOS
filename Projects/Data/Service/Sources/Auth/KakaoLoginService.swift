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
    func login() async throws -> SocialAuthResult
}

public final class KakaoLoginService: KakaoLoginServiceInterface {
    public init() {}

    @MainActor
    public func login() async throws -> SocialAuthResult {
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
                UserApi.shared.me { user, error in
                    if let error {
                        Log.debug("❌ 카카오 프로필 조회 실패: \(error.localizedDescription)")
                    }

                    let nickname = user?.kakaoAccount?.profile?.nickname
                    Log.debug("✅ 카카오 프로필 닉네임: \(nickname ?? "")")
                    continuation.resume(
                        returning: SocialAuthResult(
                            token: SocialAuthToken(
                                accessToken: oauthToken.accessToken,
                                refreshToken: oauthToken.refreshToken,
                                idToken: oauthToken.idToken
                            ),
                            suggestedName: nickname
                        )
                    )
                }
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
