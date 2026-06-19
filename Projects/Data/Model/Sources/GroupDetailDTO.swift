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
    public let attendanceStatus: String
    public let departurePlaces: [DeparturePlaceResponseDTO]
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
            attendanceStatus: AttendanceStatus(rawValue: attendanceStatus),
            departurePlaces: departurePlaces.map { $0.toEntity() }
        )
    }
}
