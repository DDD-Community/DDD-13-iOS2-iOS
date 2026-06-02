//
//  TokenRefreshService.swift
//  Networking
//

import Foundation

import Alamofire

import Utill

struct TokenRefreshService: Sendable {
    func refreshTokens(refreshToken: String) async throws -> RefreshedAuthTokens {
        let url = "\(AppEnvironment.serverBaseURL)/api/v1/auth/refresh"

        let response = await AF.request(
            url,
            method: .post,
            parameters: TokenRefreshRequestDTO(refreshToken: refreshToken),
            encoder: JSONParameterEncoder.default,
            headers: ["Content-Type": "application/json"]
        )
        .validate()
        .serializingDecodable(TokenRefreshResponseDTO.self)
        .response

        switch response.result {
        case let .success(dto):
            return RefreshedAuthTokens(
                accessToken: dto.accessToken,
                refreshToken: dto.refreshToken
            )

        case let .failure(error):
            Log.debug("토큰 리프레시 API 실패: \(error.localizedDescription)")
            throw NetworkError.refreshFailed
        }
    }
}

struct RefreshedAuthTokens: Sendable {
    let accessToken: String
    let refreshToken: String
}

private struct TokenRefreshRequestDTO: Encodable, Sendable {
    let refreshToken: String
}

private struct TokenRefreshResponseDTO: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
}
