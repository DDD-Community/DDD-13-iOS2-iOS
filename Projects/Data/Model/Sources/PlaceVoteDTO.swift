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
    public let place: PlaceVotePlaceResponseDTO
    public let voteCount: Int
    public let isMyVote: Bool
    public let travelBurdens: [PlaceTravelBurdenResponseDTO]
}

public struct PlaceVotePlaceResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let name: String
    public let categoryLabel: String
    public let address: String
}

public struct PlaceTravelBurdenResponseDTO: Decodable, Sendable {
    public let memberId: Int
    public let seconds: Int
    public let transfers: Int
    public let isLongest: Bool
}

public struct SubmitPlaceVoteRequestDTO: Encodable, Sendable {
    public let placeIds: [Int]

    public init(placeIds: [Int]) {
        self.placeIds = placeIds
    }
}

public struct StartPlaceVoteRequestDTO: Encodable, Sendable {
    public let durationDays: Int

    public init(durationDays: Int) {
        self.durationDays = durationDays
    }
}

public struct ConfirmedPlaceResultResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let placeName: String
    public let address: String
    public let confirmedAt: String
    public let candidates: [ConfirmedPlaceCandidateResponseDTO]
}

public struct ConfirmedPlaceCandidateResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let voteCount: Int
    public let totalSeconds: Int
    public let totalTransfers: Int
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
            id: place.placeId,
            name: place.name,
            categoryLabel: place.categoryLabel,
            address: place.address,
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

public extension ConfirmedPlaceResultResponseDTO {
    func toEntity() -> ConfirmedPlaceResult {
        ConfirmedPlaceResult(
            placeId: placeId,
            placeName: placeName,
            address: address,
            confirmedAt: confirmedAt,
            candidates: candidates.map { $0.toEntity() }
        )
    }
}

public extension ConfirmedPlaceCandidateResponseDTO {
    func toEntity() -> ConfirmedPlaceCandidate {
        ConfirmedPlaceCandidate(
            placeId: placeId,
            voteCount: voteCount,
            totalSeconds: totalSeconds,
            totalTransfers: totalTransfers
        )
    }
}
