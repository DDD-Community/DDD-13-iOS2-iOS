//
//  PlaceVoteParticipant.swift
//  Entity
//

import Foundation

/// 장소 투표에 참여 중인 멤버 한 명의 현황.
public struct PlaceVoteParticipant: Identifiable, Equatable, Sendable {
    public let memberId: Int
    public let name: String
    public let profileImageUrl: String?
    public let departureName: String?
    public let isMe: Bool
    /// 투표 완료 여부.
    public let voted: Bool

    public var id: Int { memberId }

    public init(
        memberId: Int,
        name: String,
        profileImageUrl: String?,
        departureName: String?,
        isMe: Bool,
        voted: Bool
    ) {
        self.memberId = memberId
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.departureName = departureName
        self.isMe = isMe
        self.voted = voted
    }
}
