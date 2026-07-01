//
//  PlacePickStatusDTO.swift
//  Model
//

import Entity

public struct PlacePickStatusResponseDTO: Decodable, Sendable {
    public let members: [MemberDTO]
    public let myPicks: [PickedPlaceDTO]

    public struct MemberDTO: Decodable, Sendable {
        public let memberId: Int
        public let nickname: String
        public let profileImageUrl: String?
        public let isMe: Bool
        public let done: Bool
    }

    public struct PickedPlaceDTO: Decodable, Sendable {
        public let placeId: Int
        public let name: String
        public let categoryLabel: String
        public let address: String
    }
}

public extension PlacePickStatusResponseDTO {
    func toEntity() -> PlacePickStatus {
        PlacePickStatus(
            members: members.map {
                PlacePickStatus.Member(
                    memberId: $0.memberId,
                    nickname: $0.nickname,
                    profileImageUrl: $0.profileImageUrl,
                    isMe: $0.isMe,
                    done: $0.done
                )
            },
            myPicks: myPicks.map {
                PlacePickStatus.PickedPlaceSummary(
                    placeId: $0.placeId,
                    name: $0.name,
                    categoryLabel: PlaceCategory(categoryLabel: $0.categoryLabel),
                    address: $0.address
                )
            }
        )
    }
}
