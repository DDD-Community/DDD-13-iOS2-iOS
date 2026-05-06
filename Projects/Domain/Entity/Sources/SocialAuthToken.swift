//
//  SocialAuthToken.swift
//  Entity
//
//  Created by yeosong on 4/25/26.
//

/// 소셜 로그인 SDK에서 발급받은 인증 토큰을 앱 공통 형태로 표현한 모델입니다.
///
/// 카카오, 애플, 네이버가 반환하는 토큰 필드가 완전히 같지는 않기 때문에
/// 모든 provider가 공통으로 사용할 수 있는 최소 필드를 기준으로 구성합니다.
/// 이후 서버 로그인 API에는 보통 `provider`와 `accessToken`을 함께 전달합니다.
public struct SocialAuthToken: Equatable, Sendable {
    /// 소셜 제공자가 발급한 access token입니다.
    /// 우리 서버가 소셜 제공자에 사용자 검증을 요청할 때 주로 사용합니다.
    public let accessToken: String

    /// 토큰 갱신에 사용할 수 있는 refresh token입니다.
    /// 일부 provider는 refresh token을 내려주지 않을 수 있으므로 optional로 둡니다.
    public let refreshToken: String?

    /// OpenID Connect 기반 인증에서 사용하는 ID token입니다.
    /// provider 설정에 따라 값이 없을 수 있으므로 optional로 둡니다.
    /// 현재 OpenId는 사용하지 않음.
    public let idToken: String?

    public init(
        accessToken: String,
        refreshToken: String? = nil,
        idToken: String? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idToken = idToken
    }
}
