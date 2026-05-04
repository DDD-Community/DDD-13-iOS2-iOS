//
//  AuthToken.swift
//  Entity
//
//  Created by DDD-iOS2 on 4/28/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

/// 서버 로그인 API 응답으로 받은 인증 토큰 도메인 모델입니다.
///
/// 소셜 로그인 후 `POST /api/v1/auth/login`의 결과를 표현합니다.
/// `registrationCompleted`로 회원가입 분기를 결정합니다.
public struct AuthToken: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let isNewMember: Bool
    public let registrationCompleted: Bool

    public init(
        accessToken: String,
        refreshToken: String,
        isNewMember: Bool,
        registrationCompleted: Bool
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isNewMember = isNewMember
        self.registrationCompleted = registrationCompleted
    }
}
