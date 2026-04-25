//
//  SocialAuthClient.swift
//  Presentation
//
//  Created by DDD-iOS2 on 4/25/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import ComposableArchitecture
import DomainInterface
import Foundation

private enum SocialAuthClientKey: DependencyKey {
    /// 기본 live 구현입니다.
    ///
    /// 실제 앱 실행 시에는 App 모듈에서 `.live`를 명시적으로 주입합니다.
    /// 이 기본값은 주입 누락을 빠르게 발견하기 위해 `notImplemented`를 던집니다.
    static let liveValue = SocialAuthClient { provider in
        throw SocialAuthClientError.notImplemented(provider)
    }

    /// 테스트 기본값입니다.
    ///
    /// 각 Feature 테스트에서는 필요한 성공/실패 케이스를 테스트 안에서 직접 override해서 사용합니다.
    static let testValue = SocialAuthClient { provider in
        throw SocialAuthClientError.notImplemented(provider)
    }
}

public extension DependencyValues {
    /// TCA DependencyValues에 등록되는 소셜 로그인 클라이언트입니다.
    ///
    /// Feature에서는 `@Dependency(\.socialAuthClient)` 형태로 주입받아 사용합니다.
    var socialAuthClient: SocialAuthClient {
        get { self[SocialAuthClientKey.self] }
        set { self[SocialAuthClientKey.self] = newValue }
    }
}
