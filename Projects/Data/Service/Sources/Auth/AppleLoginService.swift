//
//  AppleLoginService.swift
//  Service
//
import AuthenticationServices
import DomainInterface
import Entity
import UIKit
import Utill

/// Apple 로그인 SDK를 앱의 공통 소셜 로그인 토큰 형태로 변환하는 서비스입니다.
///
/// Presentation 계층이 `AuthenticationServices`에 직접 의존하지 않도록
/// Apple 인증 요청, delegate callback 처리, token 추출을 Service 계층 안에 숨깁니다.
public protocol AppleLoginServiceInterface: Sendable {
    @MainActor
    func login() async throws -> SocialAuthToken
}

/// `ASAuthorizationController`의 delegate 기반 API를 async/await 형태로 감싼 구현체입니다.
///
/// Apple 로그인 UI는 UIKit window 위에 표시되어야 하므로 MainActor에서 동작합니다.

public final class AppleLoginService: NSObject, AppleLoginServiceInterface, @unchecked Sendable {
    /// Apple 로그인 결과를 `async` 호출 지점으로 돌려주기 위해 보관하는 continuation입니다.
    /// 성공/실패 callback을 받은 뒤 반드시 resume하고 nil로 정리해야 합니다.
    private var continuation: CheckedContinuation<SocialAuthToken, Error>?

    public override init() {}
    @MainActor
    public func login() async throws -> SocialAuthToken {
        // 사용자가 버튼을 빠르게 여러 번 누르더라도 Apple 인증 요청이 중복 실행되지 않도록 방어합니다.
        guard continuation == nil else {
            throw SocialAuthClientError.underlying("🍏 이미 Apple 로그인이 진행 중입니다.")
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            // Apple ID 인증 요청을 생성하고, 최초 로그인 시 이름/이메일 제공 동의를 요청합니다.
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            // ASAuthorizationController는 delegate callback으로 결과를 전달하므로 self를 delegate로 연결합니다.
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension AppleLoginService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Apple 로그인 sheet를 표시할 기준 window를 반환합니다.
        // iOS 26부터 빈 UIWindow() 생성이 deprecated라서 현재 key window를 반드시 찾아 사용합니다.
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        else {
            preconditionFailure("❌ Apple 로그인 표시를 위한 key window를 찾을 수 없습니다.")
        }

        return window
    }
}

extension AppleLoginService: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        // Apple ID 인증 결과만 처리합니다. 다른 credential 타입이면 서버 검증에 사용할 토큰을 만들 수 없습니다.
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            resume(throwing: SocialAuthClientError.missingToken(.apple))
            return
        }

        // identityToken은 Apple이 서명한 JWT입니다.
        // 서버는 이 값을 검증해 사용자의 Apple 계정 식별자를 신뢰할 수 있습니다.
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            resume(throwing: SocialAuthClientError.missingToken(.apple))
            return
        }

        // TODO: 서버 애플 로그인 방식 확정 후 providerToken으로 identityToken을 보낼지 authorizationCode를 보낼지 결정합니다.
        resume(returning: SocialAuthToken(accessToken: identityToken, refreshToken: nil))
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 사용자가 Apple 로그인 sheet를 닫은 경우입니다. 네트워크/서버 실패와 구분해서 전달합니다.
        if let authorizationError = error as? ASAuthorizationError, authorizationError.code == .canceled {
            resume(throwing: SocialAuthClientError.underlying("🍏 Apple 로그인 취소"))
            return
        }

        resume(throwing: SocialAuthClientError.underlying(error.localizedDescription))
    }
}

private extension AppleLoginService {
    /// 성공 callback을 async 호출자에게 전달하고 continuation을 정리합니다.
    func resume(returning token: SocialAuthToken) {
        continuation?.resume(returning: token)
        continuation = nil
    }

    /// 실패 callback을 async 호출자에게 전달하고 continuation을 정리합니다.
    func resume(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
