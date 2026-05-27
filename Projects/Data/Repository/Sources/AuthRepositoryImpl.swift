//
//  AuthRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Foundation
import Model
import Networking
import Utill

/// 인증 관련 Repository 구현체
public final class AuthRepositoryImpl: AuthRepositoryProtocol {
    public init() {}
    /// provider와 providerToken을 받아와서 requestDTO를 구성하고 서버 로그인 요청
    public func login(provider: String, providerToken: String) async throws -> LoginResult {
        let requestDTO = LoginRequestDTO(provider: provider, providerToken: providerToken)
        let response: LoginResponseDTO = try await NetworkManager.shared.request(
            AuthEndPoint.login(requestDTO)
        )

        return response.toEntity()
    }

    /// 로그인과 토큰 저장 로직 분리
    public func saveAuthTokens(_ tokens: AuthTokens) {
        KeyChainManager.addItem(key: KeyChainKey.accessToken, value: tokens.accessToken)
        KeyChainManager.addItem(key: KeyChainKey.refreshToken, value: tokens.refreshToken)
    }

    /// 닉네임 검증
    public func validateNickname(_ nickname: String) async throws {
        let dto = NicknameValidateRequestDTO(nickname: nickname)
        try await NetworkManager.shared.requestVoid(
            AuthEndPoint.nicknameValidate(dto)
        )
    }

    /// 회원가입
    public func registerMember(nickname: String, agreedTermsIds: [Int], departureLabel: String, departureAddress: String, latitude: Double, longitude: Double) async throws -> RegisterMemberResult {
        let dto = RegisterMemberRequestDTO(nickname: nickname, agreedTemrsIds: agreedTermsIds, departureLabel: departureLabel, departureAddress: departureAddress, latitude: latitude, longitude: longitude)

        let response: RegisterMemberResponseDTO = try await NetworkManager.shared.request(AuthEndPoint.registerMember(dto))
        
        return response.toEntity()
    }
}
