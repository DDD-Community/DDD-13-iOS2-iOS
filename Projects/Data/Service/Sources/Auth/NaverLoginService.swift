//
//  NaverLoginService.swift
//  Service
//

import DomainInterface
import Entity
import NidThirdPartyLogin
import Utill

public protocol NaverLoginServiceInterface: Sendable {
    @MainActor
    func login() async throws -> SocialAuthToken
}

public final class NaverLoginService: NaverLoginServiceInterface {
    public init() {}

    @MainActor
    public func login() async throws -> SocialAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            NidOAuth.shared.requestLogin { result in
                switch result {
                case let .success(loginResult):
                    Log.debug("✅ 네이버 로그인 성공")
                    continuation.resume(
                        returning: SocialAuthToken(
                            accessToken: loginResult.accessToken.tokenString,
                            refreshToken: loginResult.refreshToken.tokenString,
                            idToken: nil
                        )
                    )
                case let .failure(error):
                    Log.debug("❌ 네이버 로그인 실패: \(error.localizedDescription)")
                    continuation.resume(throwing: SocialAuthClientError.underlying(error.localizedDescription))
                }
            }
        }
    }
}
