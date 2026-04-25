//
//  SocialAuthClient.swift
//  DomainInterface
//
//  Created by yeosong on 4/25/26.
//

import Entity

/// TCA Feature에서 사용할 소셜 로그인 의존성입니다.
///
/// `Presentation` 모듈은 KakaoSDK, AuthenticationServices, Naver SDK 같은
/// 외부 SDK를 직접 import하지 않고 이 클라이언트만 호출합니다.
/// 실제 구현은 App 모듈에서 `SocialAuthClient.live`로 주입합니다.
public struct SocialAuthClient: Sendable {
    /// 지정한 provider로 로그인을 시도하고, 성공 시 공통 토큰 모델을 반환합니다.
    ///
    /// `@Sendable`은 TCA Effect 내부에서 안전하게 캡처될 수 있도록 붙입니다.
    /// 실제 SDK 호출이 메인 스레드를 요구하는 경우 live 구현에서 `@MainActor`로 보장합니다.
    public var login: @Sendable (SocialAuthProvider) async throws -> SocialAuthToken

    public init(
        login: @escaping @Sendable (SocialAuthProvider) async throws -> SocialAuthToken
    ) {
        self.login = login
    }
}
