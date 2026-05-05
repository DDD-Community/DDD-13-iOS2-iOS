//
//  SocialAuthClient.swift
//  CoreDependencies
//
//  Created by DDD-iOS2 on 5/4/26.
//

import ComposableArchitecture
import DomainInterface
import Entity
import UseCase

public struct SocialAuthClient: Sendable {
    public var signIn: @Sendable (SocialAuthProvider) async throws -> AuthToken

    public init(
        signIn: @escaping @Sendable (SocialAuthProvider) async throws -> AuthToken
    ) {
        self.signIn = signIn
    }
}

public extension SocialAuthClient {
    static func live(useCase: SignInWithSocialUseCase) -> Self {
        Self { provider in
            try await useCase.execute(provider: provider)
        }
    }
}

extension SocialAuthClient: DependencyKey {
    public static var liveValue: SocialAuthClient { // tca dependencies 추가
        SocialAuthClient { provider in
            throw SocialAuthClientError.notImplemented(provider)
        }
    }

    public static var testValue: SocialAuthClient {
        SocialAuthClient { provider in
            throw SocialAuthClientError.notImplemented(provider)
        }
    }
}

public extension DependencyValues {
    var socialAuthClient: SocialAuthClient {
        get { self[SocialAuthClient.self] }
        set { self[SocialAuthClient.self] = newValue }
    }
}
