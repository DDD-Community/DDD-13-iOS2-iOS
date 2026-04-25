//
//  SocialAuthClientError.swift
//  DomainInterface
//
//  Created by yeosong on 4/25/26.
//

import Entity
import Foundation

/// 소셜 로그인 과정에서 Presentation 계층이 이해할 수 있는 공통 에러 타입입니다.
///
/// SDK별 에러 타입을 그대로 노출하면 `LoginFeature`가 특정 SDK에 의존하게 되므로,
/// live 구현에서 SDK 에러를 이 타입으로 변환해서 전달합니다.
public enum SocialAuthClientError: LocalizedError, Equatable, Sendable {
    /// 아직 연결하지 않은 provider를 호출했을 때 사용하는 임시 에러입니다.
    /// 애플/네이버 구현이 붙으면 해당 케이스는 더 이상 발생하지 않게 됩니다.
    case notImplemented(SocialAuthProvider)

    /// SDK 호출은 성공했지만 토큰이 내려오지 않은 비정상 케이스입니다.
    case missingToken(SocialAuthProvider)

    /// SDK나 시스템에서 내려준 에러 메시지를 공통 에러로 감싼 케이스입니다.
    case underlying(String)

    public var errorDescription: String? {
        switch self {
        case let .notImplemented(provider):
            return "\(provider.displayName) 로그인은 아직 구현되지 않았습니다."
        case let .missingToken(provider):
            return "\(provider.displayName) 로그인 토큰을 찾을 수 없습니다."
        case let .underlying(message):
            return message
        }
    }
}
