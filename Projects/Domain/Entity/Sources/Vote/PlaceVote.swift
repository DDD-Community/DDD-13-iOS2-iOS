//
//  PlaceVote.swift
//  Entity
//

import Foundation

/// 장소 투표 현황. 후보 장소별 득표 수와 멤버별 이동 부담을 제공한다.
public struct PlaceVote: Equatable, Sendable {
    public let deadline: String?
    public let sessionStatus: VoteSessionStatus
    public let totalParticipants: Int
    public let votedCount: Int
    public let candidates: [PlaceVoteCandidate]

    public init(
        deadline: String?,
        sessionStatus: VoteSessionStatus,
        totalParticipants: Int,
        votedCount: Int,
        candidates: [PlaceVoteCandidate]
    ) {
        self.deadline = deadline
        self.sessionStatus = sessionStatus
        self.totalParticipants = totalParticipants
        self.votedCount = votedCount
        self.candidates = candidates
    }
}

public struct PlaceVoteCandidate: Identifiable, Equatable, Sendable {
    public let id: Int
    public let voteCount: Int
    public let isMyVote: Bool
    public let travelBurdens: [PlaceTravelBurden]

    public var placeId: Int { id }

    public init(
        id: Int,
        voteCount: Int,
        isMyVote: Bool,
        travelBurdens: [PlaceTravelBurden]
    ) {
        self.id = id
        self.voteCount = voteCount
        self.isMyVote = isMyVote
        self.travelBurdens = travelBurdens
    }
}

public struct PlaceTravelBurden: Identifiable, Equatable, Sendable {
    public let id: Int
    public let seconds: Int
    public let transfers: Int
    public let isLongest: Bool

    public var memberId: Int { id }

    public init(
        id: Int,
        seconds: Int,
        transfers: Int,
        isLongest: Bool
    ) {
        self.id = id
        self.seconds = seconds
        self.transfers = transfers
        self.isLongest = isLongest
    }
}
