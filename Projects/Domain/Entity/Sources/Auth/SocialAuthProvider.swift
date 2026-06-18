//
//  SocialAuthProvider.swift
//  Entity
//

/// `LoginFeature`는 이 enum 값만 보고 어떤 소셜 로그인을 요청할지 결정합니다.
/// 각 제공자의 실제 SDK 타입이나 구현 방식은 `Presentation` 모듈 밖에서 처리합니다.
public enum SocialAuthProvider: Equatable, Sendable {
    case kakao
    case apple
    case naver
}

public extension SocialAuthProvider {
    /// 사용자에게 보여줄 에러 메시지를 만들 때 사용하는 provider 이름입니다.
    var displayName: String {
        switch self {
        case .kakao:
            return "카카오"
        case .apple:
            return "애플"
        case .naver:
            return "네이버"
        }
    }

    /// 서버 API 요청 시 사용하는 provider 식별 문자열입니다.
    var serverValue: String {
        switch self {
        case .kakao:
            return "KAKAO"
        case .apple:
            return "APPLE"
        case .naver:
            return "NAVER"
        }
    }
}
