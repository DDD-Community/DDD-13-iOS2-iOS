//
//  PlaceVote.swift
//  Entity
//

import Foundation

/// 장소 투표 현황. 후보 장소별 득표 수와 멤버별 투표 완료 상태를 제공한다.
public struct PlaceVote: Equatable, Sendable {
    public let deadline: String?
    public let sessionStatus: VoteSessionStatus
    public let totalParticipants: Int
    public let votedCount: Int
    public let memberStatuses: [PlaceVoteMemberStatus]
    public let candidates: [PlaceVoteCandidate]

    public init(
        deadline: String?,
        sessionStatus: VoteSessionStatus,
        totalParticipants: Int,
        votedCount: Int,
        memberStatuses: [PlaceVoteMemberStatus],
        candidates: [PlaceVoteCandidate]
    ) {
        self.deadline = deadline
        self.sessionStatus = sessionStatus
        self.totalParticipants = totalParticipants
        self.votedCount = votedCount
        self.memberStatuses = memberStatuses
        self.candidates = candidates
    }
}

/// 멤버별 장소 투표 완료 여부.
public struct PlaceVoteMemberStatus: Identifiable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let completed: Bool

    public var memberId: Int { id }

    public init(
        id: Int,
        name: String,
        completed: Bool
    ) {
        self.id = id
        self.name = name
        self.completed = completed
    }
}

public struct PlaceVoteCandidate: Identifiable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let categoryLabel: PlaceCategory
    public let address: String
    public let latitude: Double?
    public let longitude: Double?
    public let voteCount: Int
    public let isMyVote: Bool

    public var placeId: Int { id }

    public init(
        id: Int,
        name: String,
        categoryLabel: PlaceCategory,
        address: String,
        latitude: Double?,
        longitude: Double?,
        voteCount: Int,
        isMyVote: Bool
    ) {
        self.id = id
        self.name = name
        self.categoryLabel = categoryLabel
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.voteCount = voteCount
        self.isMyVote = isMyVote
    }
}
