//
//  SignupTermsClient.swift
//  CoreDependencies
//

import ComposableArchitecture
import Entity
import UseCase

@DependencyClient
public struct SignupTermsClient: Sendable {
    public var fetchSignupTerms: @Sendable () async throws -> [SignupTerm]
}

public extension SignupTermsClient {
    static func live(useCase: SignupTermsUseCase) -> Self {
        Self {
            try await useCase.execute()
        }
    }
}

extension SignupTermsClient: DependencyKey {
    public static let liveValue = SignupTermsClient()
    public static let testValue = SignupTermsClient(
            fetchSignupTerms: {
                [
                    SignupTerm(
                        id: 1,
                        type: "SERVICE",
                        title: "서비스 이용약관 테스트",
                        content: "서비스 이용약관 내용입니다.",
                        isRequired: true
                    ),
                    SignupTerm(
                        id: 2,
                        type: "PRIVACY",
                        title: "개인정보 수집 및 이용 동의 테스트",
                        content: "개인정보 수집 및 이용 동의 내용입니다.",
                        isRequired: true
                    ),
                    SignupTerm(
                        id: 3,
                        type: "LOCATION",
                        title: "위치정보 수집 이용 동의 테스트",
                        content: "위치정보 수집 이용 동의 내용입니다.",
                        isRequired: true
                    )
                ]
            }
        )
}

public extension DependencyValues {
    var signupTermsClient: SignupTermsClient {
        get { self[SignupTermsClient.self] }
        set { self[SignupTermsClient.self] = newValue }
    }
}
