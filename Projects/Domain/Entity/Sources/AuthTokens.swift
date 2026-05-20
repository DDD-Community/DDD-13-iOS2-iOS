//
//  AuthTokens.swift
//  Entity
//

/// 인증에 사용하는 액세스/리프레시 토큰 쌍입니다.
public struct AuthTokens: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    public init(
        accessToken: String,
        refreshToken: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
