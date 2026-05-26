//
//  SocialAuthResult.swift
//  Entity
//
//

public struct SocialAuthResult: Equatable, Sendable {
    public let token: SocialAuthToken
    public let suggestedName: String?

    public init(
        token: SocialAuthToken,
        suggestedName: String? = nil
    ) {
        self.token = token
        self.suggestedName = suggestedName
    }
}
