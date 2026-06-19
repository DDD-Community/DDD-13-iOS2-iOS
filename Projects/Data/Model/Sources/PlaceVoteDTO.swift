//
//  PlaceVoteDTO.swift
//  Model
//

import Entity

public struct PlaceVoteResponseDTO: Decodable, Sendable {
    public let deadline: String?
    public let sessionStatus: String
    public let totalParticipants: Int
    public let votedCount: Int
    public let candidates: [PlaceVoteCandidateResponseDTO]
}

public struct PlaceVoteCandidateResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let voteCount: Int
    public let isMyVote: Bool
    public let travelBurdens: [PlaceTravelBurdenResponseDTO]
}

public struct PlaceTravelBurdenResponseDTO: Decodable, Sendable {
    public let memberId: Int
    public let seconds: Int
    public let transfers: Int
    public let isLongest: Bool
}

// MARK: - toEntity

public extension PlaceVoteResponseDTO {
    func toEntity() -> PlaceVote {
        PlaceVote(
            deadline: deadline,
            sessionStatus: VoteSessionStatus(rawValue: sessionStatus),
            totalParticipants: totalParticipants,
            votedCount: votedCount,
            candidates: candidates.map { $0.toEntity() }
        )
    }
}

public extension PlaceVoteCandidateResponseDTO {
    func toEntity() -> PlaceVoteCandidate {
        PlaceVoteCandidate(
            id: placeId,
            voteCount: voteCount,
            isMyVote: isMyVote,
            travelBurdens: travelBurdens.map { $0.toEntity() }
        )
    }
}

public extension PlaceTravelBurdenResponseDTO {
    func toEntity() -> PlaceTravelBurden {
        PlaceTravelBurden(
            id: memberId,
            seconds: seconds,
            transfers: transfers,
            isLongest: isLongest
        )
    }
}
