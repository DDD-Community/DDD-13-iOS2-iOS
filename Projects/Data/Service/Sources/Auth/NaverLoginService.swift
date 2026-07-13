//
//  NaverLoginService.swift
//  Service
//

import NidThirdPartyLogin

import DomainInterface
import Entity
import Utill

public protocol NaverLoginServiceInterface: Sendable {
    @MainActor
    func login() async throws -> SocialAuthResult
}

public final class NaverLoginService: NaverLoginServiceInterface {
    public init() {}

    @MainActor
    public func login() async throws -> SocialAuthResult {
        try await withCheckedThrowingContinuation { continuation in
            NidOAuth.shared.requestLogin { result in
                switch result {
                case let .success(loginResult):
                    Log.debug("✅ 네이버 로그인 성공")
                    let accessToken = loginResult.accessToken.tokenString
                    NidOAuth.shared.getUserProfile(accessToken: accessToken) { profileResult in
                        let name: String?
                        switch profileResult {
                        case let .success(profile):
                            name = profile["name"]
                            Log.debug("✅ 네이버 프로필 이름: \(name ?? "")")

                        case let .failure(error):
                            name = nil
                            Log.debug("❌ 네이버 프로필 조회 실패: \(error.localizedDescription)")
                        }

                        continuation.resume(
                            returning: SocialAuthResult(
                                token: SocialAuthToken(
                                    accessToken: accessToken,
                                    refreshToken: loginResult.refreshToken.tokenString,
                                    idToken: nil
                                ),
                                suggestedName: name
                            )
                        )
                    }

                case let .failure(error):
                    Log.debug("❌ 네이버 로그인 실패: \(error.localizedDescription)")
                    continuation.resume(throwing: SocialAuthClientError.underlying(error.localizedDescription))
                }
            }
        }
    }
}
