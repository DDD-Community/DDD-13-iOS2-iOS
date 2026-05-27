//
//  LoginResult.swift
//  Entity
//

/// 서버 로그인 API 응답으로 받은 로그인 결과 도메인 모델입니다.
public struct LoginResult: Equatable, Sendable {
    public let tokens: AuthTokens
    public let firstSocialLogin: Bool
    public let registrationCompleted: Bool
    public let suggestedName: String?

    public init(
        tokens: AuthTokens,
        firstSocialLogin: Bool,
        registrationCompleted: Bool,
        suggestedName: String? = nil
    ) {
        self.tokens = tokens
        self.firstSocialLogin = firstSocialLogin
        self.registrationCompleted = registrationCompleted
        self.suggestedName = suggestedName
    }
}
