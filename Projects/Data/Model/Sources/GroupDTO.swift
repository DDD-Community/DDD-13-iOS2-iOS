//
//  GroupDTO.swift
//  Model
//

import Entity

public struct GroupListItemResponseDTO: Decodable, Sendable {
    public let groupId: Int64
    public let meetingId: Int64
    public let name: String
    public let themeTagCode: String
    public let themeTagDisplay: String
    public let listStatus: String
    public let locationStatus: String
    public let dateVoteStatus: String
    public let locationAddress: String?
    public let memberCount: Int
    public let members: [GroupMemberResponseDTO]
}

public struct GroupMemberResponseDTO: Decodable, Sendable {
    public let memberId: Int64
    public let nickname: String
    public let profileImageUrl: String?
    public let attendanceStatus: String
}

public struct CreateGroupRequestDTO: Encodable, Sendable {
    public let name: String
    public let themeTagCode: String

    public init(name: String, themeTagCode: String) {
        self.name = name
        self.themeTagCode = themeTagCode
    }
}

public struct CreateGroupResponseDTO: Decodable, Sendable {
    public let groupId: Int64
    public let meetingId: Int64
    public let name: String
    public let themeTagCode: String
}

public struct HostPickMeetingDateRequestDTO: Encodable, Sendable {
    public let date: String

    public init(date: String) {
        self.date = date
    }
}

// MARK: - toEntity

public extension GroupListItemResponseDTO {
    func toEntity() -> Group {
        Group(
            id: groupId,
            meetingId: meetingId,
            name: name,
            themeTagCode: themeTagCode,
            themeTagDisplay: themeTagDisplay,
            listStatus: GroupListStatus(rawValue: listStatus),
            locationStatus: GroupLocationStatus(rawValue: locationStatus),
            dateVoteStatus: GroupDateVoteStatus(rawValue: dateVoteStatus),
            locationAddress: locationAddress,
            memberCount: memberCount,
            members: members.map { $0.toEntity() }
        )
    }
}

public extension GroupMemberResponseDTO {
    func toEntity() -> GroupMember {
        GroupMember(
            id: memberId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            attendanceStatus: GroupAttendanceStatus(rawValue: attendanceStatus)
        )
    }
}

public extension CreateGroupResponseDTO {
    func toEntity() -> CreateGroupResult {
        CreateGroupResult(
            groupId: groupId,
            meetingId: meetingId,
            name: name,
            themeTagCode: themeTagCode
        )
    }
}
