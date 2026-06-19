//
//  DateVote.swift
//  Entity
//

import Foundation

/// 날짜 투표 현황. 후보 날짜별 득표 수와 투표자 목록을 제공한다.
public struct DateVote: Equatable, Sendable {
    public let dateVoteStatus: GroupDateVoteStatus
    public let sessionStatus: VoteSessionStatus
    public let deadline: String?
    public let options: [DateVoteOption]

    public init(
        dateVoteStatus: GroupDateVoteStatus,
        sessionStatus: VoteSessionStatus,
        deadline: String?,
        options: [DateVoteOption]
    ) {
        self.dateVoteStatus = dateVoteStatus
        self.sessionStatus = sessionStatus
        self.deadline = deadline
        self.options = options
    }
}

public struct DateVoteOption: Identifiable, Equatable, Sendable {
    public let id: Int64
    public let candidateDate: String
    public let voteCount: Int
    public let isMyVote: Bool
    public let voters: [DateVoteVoter]

    public var optionId: Int64 { id }

    public init(
        id: Int64,
        candidateDate: String,
        voteCount: Int,
        isMyVote: Bool,
        voters: [DateVoteVoter]
    ) {
        self.id = id
        self.candidateDate = candidateDate
        self.voteCount = voteCount
        self.isMyVote = isMyVote
        self.voters = voters
    }
}

public struct DateVoteVoter: Identifiable, Equatable, Sendable {
    public let id: Int64
    public let nickname: String
    public let profileImageUrl: String?

    public var memberId: Int64 { id }

    public init(
        id: Int64,
        nickname: String,
        profileImageUrl: String?
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
    }
}
