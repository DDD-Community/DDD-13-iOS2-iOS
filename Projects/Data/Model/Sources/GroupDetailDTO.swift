//
//  GroupDetailDTO.swift
//  Model
//

import Entity

public struct GroupDetailResponseDTO: Decodable, Sendable {
    public let meetingId: Int64
    public let name: String
    public let themeTagCode: String
    public let themeTagDisplay: String
    public let locationStatus: String
    public let dateVoteStatus: String
    public let confirmedDate: String?
    public let members: [GroupDetailMemberResponseDTO]
}

public struct GroupDetailMemberResponseDTO: Decodable, Sendable {
    public let memberId: Int64
    public let nickname: String
    public let profileImageUrl: String?
    public let isHost: Bool
    public let isMe: Bool
    public let departurePlaces: [DeparturePlaceResponseDTO]
}

public struct DeparturePlaceResponseDTO: Decodable, Sendable {
    public let id: Int64
    public let label: String
    public let address: String
    public let roadAddress: String
    public let placeName: String
    public let latitude: Double
    public let longitude: Double
    public let isDefault: Bool
}

public struct UpdateAttendanceRequestDTO: Encodable, Sendable {
    public let attendanceStatus: String

    public init(attendanceStatus: String) {
        self.attendanceStatus = attendanceStatus
    }
}

// MARK: - toEntity

public extension GroupDetailResponseDTO {
    func toEntity() -> GroupDetail {
        GroupDetail(
            id: meetingId,
            name: name,
            themeTagCode: themeTagCode,
            themeTagDisplay: themeTagDisplay,
            locationStatus: GroupLocationStatus(rawValue: locationStatus),
            dateVoteStatus: GroupDateVoteStatus(rawValue: dateVoteStatus),
            confirmedDate: confirmedDate,
            members: members.map { $0.toEntity() }
        )
    }
}

public extension GroupDetailMemberResponseDTO {
    func toEntity() -> GroupDetailMember {
        GroupDetailMember(
            id: memberId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            isHost: isHost,
            isMe: isMe,
            departurePlaces: departurePlaces.map { $0.toEntity() }
        )
    }
}

public extension DeparturePlaceResponseDTO {
    func toEntity() -> DeparturePlace {
        DeparturePlace(
            id: id,
            label: label,
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude,
            isDefault: isDefault
        )
    }
}
