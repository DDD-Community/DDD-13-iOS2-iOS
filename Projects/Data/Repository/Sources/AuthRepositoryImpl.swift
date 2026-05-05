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

/// 인증 관련 Repository 구현체
public struct AuthRepositoryImpl: AuthRepositoryProtocol {
    public init() {}
    // provider와 providerToken을 받아와서 requestDTO를 구성하고 서버 로그인 요청
    public func login(provider: String, providerToken: String) async throws -> AuthToken {
        let requestDTO = LoginRequestDTO(provider: provider, providerToken: providerToken)
        let response: LoginResponseDTO = try await NetworkManager.shared.request(
            AuthEndPoint.login(requestDTO)
        )

        return response.toEntity()
    }
}
