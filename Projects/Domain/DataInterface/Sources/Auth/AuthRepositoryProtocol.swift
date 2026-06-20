//
//  AuthRepositoryProtocol.swift
//  DataInterface
//

import Dependencies
import Entity

/// 인증 관련 데이터 소스 접근을 추상화하는 Repository 프로토콜
public protocol AuthRepositoryProtocol: Sendable {
    /// 소셜 로그인 토큰으로 서버 로그인을 요청합니다.
    func login(provider: String, providerToken: String) async throws -> LoginResult
    func saveAuthTokens(_ tokens: AuthTokens) // 토큰 저장
    func saveRegistrationCompleted(_ completed: Bool) // 회원 가입 완료 여부
    func validateNickname(_ nickname: String) async throws
    func registerMember(
        _ member: RegisterMember
    ) async throws -> RegisterMemberResult
}

/// 테스트/프리뷰용 기본 mock 구현체.
/// `liveValue`가 주입되지 않은 환경에서 크래시 없이 결정적 결과를 반환하기 위한 Null Object.
public struct DefaultAuthRepositoryImpl: AuthRepositoryProtocol {
    public init() {}

    public func login(provider _: String, providerToken _: String) async throws -> LoginResult {
        LoginResult(
            tokens: AuthTokens(
                accessToken: "mock-access-token",
                refreshToken: "mock-refresh-token"
            ),
            firstSocialLogin: true,
            registrationCompleted: true
        )
    }

    public func saveAuthTokens(_: AuthTokens) {
        // no-op: 테스트/프리뷰에서는 키체인 쓰기를 건너뜁니다.
    }

    public func saveRegistrationCompleted(_: Bool) {
        // no-op: 테스트/프리뷰에서는 회원가입 완료 상태 저장을 건너뜁니다.
    }

    public func validateNickname(_: String) async throws {
        // no-op: 테스트/프리뷰에서는 항상 사용 가능한 닉네임으로 간주합니다.
    }

    public func registerMember(_ member: RegisterMember) async throws -> RegisterMemberResult {
        RegisterMemberResult(
            id: 0,
            nickname: member.nickname,
            profileImageUrl: nil,
            socialProvider: "mock",
            registrationCompleted: true
        )
    }
}
