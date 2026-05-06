//
//  AuthRepositoryProtocol.swift
//  DataInterface
//
//  Created by DDD-iOS2 on 4/28/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import Entity

/// 인증 관련 데이터 소스 접근을 추상화하는 Repository 프로토콜
public protocol AuthRepositoryProtocol: Sendable {
    /// 소셜 로그인 토큰으로 서버 로그인을 요청합니다.
    func login(provider: String, providerToken: String) async throws -> LoginResult
    func saveAuthTokens(_ tokens: AuthTokens)
}
