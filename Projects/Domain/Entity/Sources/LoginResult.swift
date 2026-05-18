//
//  LoginResult.swift
//  Entity
//

/// 서버 로그인 API 응답으로 받은 로그인 결과 도메인 모델입니다.
public struct LoginResult: Equatable, Sendable {
    public let tokens: AuthTokens
    public let isNewMember: Bool
    public let registrationCompleted: Bool

    public init(
        tokens: AuthTokens,
        isNewMember: Bool,
        registrationCompleted: Bool
    ) {
        self.tokens = tokens
        self.isNewMember = isNewMember
        self.registrationCompleted = registrationCompleted
    }
}
