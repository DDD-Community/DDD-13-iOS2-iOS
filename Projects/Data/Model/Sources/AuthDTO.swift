//
//  AuthDTO.swift
//  Model
//

import Entity
import Foundation

/// 서버 로그인 API 요청 바디
public struct LoginRequestDTO: Encodable, Sendable {
    public let provider: String
    public let providerToken: String

    public init(provider: String, providerToken: String) {
        self.provider = provider
        self.providerToken = providerToken
    }
}

/// 서버 닉네임 검증 API 요청 바디
public struct NicknameValidateRequestDTO: Encodable, Sendable {
    public let nickname: String

    public init(nickname: String) {
        self.nickname = nickname
    }
}

/// 회원 가입 API 요청 바디
public struct RegisterMemberRequestDTO: Encodable, Sendable {
    public let nickname: String
    public let agreedTemrsIds: [Int]
    public let departureLabel: String
    public let departureAddress: String
    public let latitude: Double
    public let longitude: Double
    
    public init(nickname: String, agreedTemrsIds: [Int], departureLabel: String, departureAddress: String, latitude: Double, longitude: Double) {
        self.nickname = nickname
        self.agreedTemrsIds = agreedTemrsIds
        self.departureLabel = departureLabel
        self.departureAddress = departureAddress
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// 회원 가입 API 응답 데이터
public struct RegisterMemberResponseDTO: Codable, Sendable {
    public let id: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let socialProvider: String
    public let registrationCompleted: Bool
}

/// 서버 로그인 API 응답 데이터
public struct LoginResponseDTO: Codable, Sendable {
    public let accessToken: String // 액세스 토큰
    public let refreshToken: String // 리프레시 토큰
    public let firstSocialLogin: Bool // 최초 생성한 회원 여부
    public let registrationCompleted: Bool // 회원가입 완료 여부 -> 닉네임 설정 완료까지 하면 true
    // registrationCompleted가 true인 회원만 메인화면으로 아니면 회원가입 화면
}

public extension LoginResponseDTO { // 엔티티 변환 함수 추가
    func toEntity() -> LoginResult {
        LoginResult(
            tokens: AuthTokens(
                accessToken: accessToken,
                refreshToken: refreshToken
            ),
            firstSocialLogin: firstSocialLogin,
            registrationCompleted: registrationCompleted
        )
    }
}

public extension RegisterMemberResponseDTO {
    func toEntity() -> RegisterMemberResult {
        RegisterMemberResult(id: id, nickname: nickname, profileImageUrl: profileImageUrl, socialProvider: socialProvider, registrationCompleted: registrationCompleted)
    }
}
