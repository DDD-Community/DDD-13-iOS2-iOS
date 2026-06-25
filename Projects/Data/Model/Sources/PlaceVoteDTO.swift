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
    public let memberStatuses: [PlaceVoteMemberStatusResponseDTO]
    public let candidates: [PlaceVoteCandidateResponseDTO]
}

public struct PlaceVoteMemberStatusResponseDTO: Decodable, Sendable {
    public let memberId: Int
    public let name: String
    public let completed: Bool
}

public struct PlaceVoteCandidateResponseDTO: Decodable, Sendable {
    public let place: PlaceVotePlaceResponseDTO
    public let voteCount: Int
    public let isMyVote: Bool
}

public struct PlaceVotePlaceResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let name: String
    public let categoryLabel: String
    public let address: String
    public let latitude: Double?
    public let longitude: Double?
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
    // TODO: 서버에 확정 장소 좌표 응답이 추가되면 non-optional로 전환
    public let latitude: Double?
    public let longitude: Double?
    public let confirmedAt: String
    public let candidates: [ConfirmedPlaceCandidateResponseDTO]
}

public struct ConfirmedPlaceCandidateResponseDTO: Decodable, Sendable {
    public let placeId: Int
    public let voteCount: Int
    public let totalSeconds: Int
    public let totalTransfers: Int
}

public struct PlaceVoteTravelBurdenResponseDTO: Decodable, Sendable {
    public let place: PlaceVotePlaceResponseDTO
    public let burdens: [MemberTravelBurdenResponseDTO]
}

public struct MemberTravelBurdenResponseDTO: Decodable, Sendable {
    public let memberId: Int
    public let name: String
    public let departureName: String
    public let isMe: Bool
    public let seconds: Int
    public let transfers: Int
    public let isLongest: Bool
    public let path: [TravelPathPointResponseDTO]
}

public struct TravelPathPointResponseDTO: Decodable, Sendable {
    public let stationId: Int
    public let latitude: Double
    public let longitude: Double
}

public struct PlaceVoteParticipantsResponseDTO: Decodable, Sendable {
    public let participants: [PlaceVoteParticipantResponseDTO]
}

public struct PlaceVoteParticipantResponseDTO: Decodable, Sendable {
    public let memberId: Int
    public let name: String
    public let profileImageUrl: String?
    public let departureName: String?
    public let isMe: Bool
    public let voted: Bool
}

// MARK: - toEntity

public extension PlaceVoteResponseDTO {
    func toEntity() -> PlaceVote {
        PlaceVote(
            deadline: deadline,
            sessionStatus: VoteSessionStatus(rawValue: sessionStatus),
            totalParticipants: totalParticipants,
            votedCount: votedCount,
            memberStatuses: memberStatuses.map { $0.toEntity() },
            candidates: candidates.map { $0.toEntity() }
        )
    }
}

public extension PlaceVoteMemberStatusResponseDTO {
    func toEntity() -> PlaceVoteMemberStatus {
        PlaceVoteMemberStatus(
            id: memberId,
            name: name,
            completed: completed
        )
    }
}

public extension PlaceVoteCandidateResponseDTO {
    func toEntity() -> PlaceVoteCandidate {
        PlaceVoteCandidate(
            id: place.placeId,
            name: place.name,
            categoryLabel: PlaceCategory(categoryLabel: place.categoryLabel),
            address: place.address,
            latitude: place.latitude,
            longitude: place.longitude,
            voteCount: voteCount,
            isMyVote: isMyVote
        )
    }
}

public extension ConfirmedPlaceResultResponseDTO {
    func toEntity() -> ConfirmedPlaceResult {
        ConfirmedPlaceResult(
            placeId: placeId,
            placeName: placeName,
            address: address,
            latitude: latitude,
            longitude: longitude,
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

public extension PlaceVoteTravelBurdenResponseDTO {
    func toEntity() -> PlaceVoteTravelBurden {
        PlaceVoteTravelBurden(
            place: TravelBurdenPlace(
                placeId: place.placeId,
                name: place.name,
                categoryLabel: PlaceCategory(categoryLabel: place.categoryLabel),
                address: place.address,
                latitude: place.latitude,
                longitude: place.longitude
            ),
            burdens: burdens.map { $0.toEntity() }
        )
    }
}

public extension MemberTravelBurdenResponseDTO {
    func toEntity() -> MemberTravelBurden {
        MemberTravelBurden(
            memberId: memberId,
            name: name,
            departureName: departureName,
            isMe: isMe,
            seconds: seconds,
            transfers: transfers,
            isLongest: isLongest,
            path: path.map { $0.toEntity() }
        )
    }
}

public extension TravelPathPointResponseDTO {
    func toEntity() -> TravelPathPoint {
        TravelPathPoint(
            stationId: stationId,
            latitude: latitude,
            longitude: longitude
        )
    }
}

public extension PlaceVoteParticipantsResponseDTO {
    func toEntity() -> [PlaceVoteParticipant] {
        participants.map { $0.toEntity() }
    }
}

public extension PlaceVoteParticipantResponseDTO {
    func toEntity() -> PlaceVoteParticipant {
        PlaceVoteParticipant(
            memberId: memberId,
            name: name,
            profileImageUrl: profileImageUrl,
            departureName: departureName,
            isMe: isMe,
            voted: voted
        )
    }
}
