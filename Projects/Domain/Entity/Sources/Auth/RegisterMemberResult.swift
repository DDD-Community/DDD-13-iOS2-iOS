//
//  RegisterMemberResult.swift
//  Entity
//

/// 회원가입 완료 후 응답으로 받은 회원가입 결과 도메인 엔티티
public struct RegisterMemberResult: Equatable, Sendable {
    public let id: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let socialProvider: String
    public let registrationCompleted: Bool

    public init(id: Int, nickname: String, profileImageUrl: String?, socialProvider: String, registrationCompleted: Bool) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.socialProvider = socialProvider
        self.registrationCompleted = registrationCompleted
    }
}
