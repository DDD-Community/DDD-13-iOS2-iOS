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
    func saveAuthTokens(_ tokens: AuthTokens)
}

// MARK: - 이건 추천 입니다만 이런식으로 depdency 하시는거 어떠신지 ??

/// Auth Repository 의 DependencyKey 구조체
public struct AuthRepositoryDependency: DependencyKey {
    public static var liveValue: AuthRepositoryProtocol {
        fatalError("AuthRepositoryDependency liveValue not implemented")
    }

    public static var testValue: AuthRepositoryProtocol {
        DefaultAuthRepositoryImpl()
    }

    public static let previewValue: AuthRepositoryProtocol = liveValue
}

public extension DependencyValues {
    var authRepository: AuthRepositoryProtocol {
        get { self[AuthRepositoryDependency.self] }
        set { self[AuthRepositoryDependency.self] = newValue }
    }
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
            isNewMember: false,
            registrationCompleted: true
        )
    }

    public func saveAuthTokens(_: AuthTokens) {
        // no-op: 테스트/프리뷰에서는 키체인 쓰기를 건너뜁니다.
    }
}
