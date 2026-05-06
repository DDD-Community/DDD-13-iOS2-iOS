//
//  AuthRepositoryImpl.swift
//  Repository
//
//  Created by DDD-iOS2 on 4/28/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import Foundation
import Networking
import DataInterface
import Model
import API
import Entity
import Utill

/// 인증 관련 Repository 구현체
public final class AuthRepositoryImpl: AuthRepositoryProtocol {
    public init() {}
    // provider와 providerToken을 받아와서 requestDTO를 구성하고 서버 로그인 요청
    public func login(provider: String, providerToken: String) async throws -> LoginResult {
        let requestDTO = LoginRequestDTO(provider: provider, providerToken: providerToken)
        let response: LoginResponseDTO = try await NetworkManager.shared.request(
            AuthEndPoint.login(requestDTO)
        )

        return response.toEntity()
    }

    public func saveAuthTokens(_ tokens: AuthTokens) {
        KeyChainManager.addItem(key: KeyChainKey.accessToken, value: tokens.accessToken)
        KeyChainManager.addItem(key: KeyChainKey.refreshToken, value: tokens.refreshToken)
    }
}
