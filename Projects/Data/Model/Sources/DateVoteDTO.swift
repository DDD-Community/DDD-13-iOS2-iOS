//
//  DateVoteDTO.swift
//  Model
//

import Entity

public struct DateVoteResponseDTO: Decodable, Sendable {
    public let dateVoteStatus: String
    public let sessionStatus: String
    public let deadline: String?
    public let options: [DateVoteOptionResponseDTO]
}

public struct DateVoteOptionResponseDTO: Decodable, Sendable {
    public let optionId: Int
    public let candidateDate: String
    public let voteCount: Int
    public let isMyVote: Bool
    public let voters: [DateVoteVoterResponseDTO]
}

public struct DateVoteVoterResponseDTO: Decodable, Sendable {
    public let memberId: Int
    // TODO: 가입 미완료 테스트 계정으로 인한 임시 옵셔널 처리. 테스트 계정 정리 후 non-optional(String)로 복구
    public let nickname: String?
    public let profileImageUrl: String?
}

// MARK: - Request DTO

public struct SubmitDateVoteRequestDTO: Encodable, Sendable {
    public let optionIds: [Int]

    public init(optionIds: [Int]) {
        self.optionIds = optionIds
    }
}

public struct ConfirmDateVoteRequestDTO: Encodable, Sendable {
    public let optionId: Int

    public init(optionId: Int) {
        self.optionId = optionId
    }
}

// MARK: - toEntity

public extension DateVoteResponseDTO {
    func toEntity() -> DateVote {
        DateVote(
            dateVoteStatus: GroupDateVoteStatus(rawValue: dateVoteStatus),
            sessionStatus: VoteSessionStatus(rawValue: sessionStatus),
            deadline: deadline,
            options: options.map { $0.toEntity() }
        )
    }
}

public extension DateVoteOptionResponseDTO {
    func toEntity() -> DateVoteOption {
        DateVoteOption(
            id: optionId,
            candidateDate: candidateDate,
            voteCount: voteCount,
            isMyVote: isMyVote,
            voters: voters.map { $0.toEntity() }
        )
    }
}

public extension DateVoteVoterResponseDTO {
    func toEntity() -> DateVoteVoter {
        DateVoteVoter(
            id: memberId,
            nickname: nickname ?? "테스트멤버",
            profileImageUrl: profileImageUrl
        )
    }
}
