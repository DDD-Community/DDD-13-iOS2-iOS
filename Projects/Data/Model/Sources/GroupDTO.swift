//
//  GroupDTO.swift
//  Model
//

import Entity

public struct GroupListItemResponseDTO: Decodable, Sendable {
    public let groupId: Int
    public let meetingId: Int
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
    public let memberId: Int
    // TODO: 가입 미완료 테스트 계정으로 인한 임시 옵셔널 처리. 테스트 계정 정리 후 non-optional(String)로 복구
    public let nickname: String?
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
    public let groupId: Int
    public let meetingId: Int
    public let name: String
    public let themeTagCode: String
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
            nickname: nickname ?? "테스트멤버",
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
