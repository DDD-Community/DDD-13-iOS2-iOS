//
//  Group.swift
//  Entity
//

import Foundation

public struct Group: Identifiable, Equatable, Sendable {
    public let id: Int64
    public let meetingId: Int64
    public let name: String
    public let themeTagCode: String
    public let themeTagDisplay: String
    public let listStatus: GroupListStatus
    public let locationStatus: GroupLocationStatus
    public let dateVoteStatus: GroupDateVoteStatus
    public let locationAddress: String?
    public let memberCount: Int
    public let members: [GroupMember]

    public init(
        id: Int64,
        meetingId: Int64,
        name: String,
        themeTagCode: String,
        themeTagDisplay: String,
        listStatus: GroupListStatus,
        locationStatus: GroupLocationStatus,
        dateVoteStatus: GroupDateVoteStatus,
        locationAddress: String?,
        memberCount: Int,
        members: [GroupMember]
    ) {
        self.id = id
        self.meetingId = meetingId
        self.name = name
        self.themeTagCode = themeTagCode
        self.themeTagDisplay = themeTagDisplay
        self.listStatus = listStatus
        self.locationStatus = locationStatus
        self.dateVoteStatus = dateVoteStatus
        self.locationAddress = locationAddress
        self.memberCount = memberCount
        self.members = members
    }
}

public struct GroupMember: Identifiable, Equatable, Sendable {
    public let id: Int64
    public let nickname: String
    public let profileImageUrl: String?
    public let attendanceStatus: GroupAttendanceStatus

    public init(
        id: Int64,
        nickname: String,
        profileImageUrl: String?,
        attendanceStatus: GroupAttendanceStatus
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.attendanceStatus = attendanceStatus
    }
}

public enum GroupListStatus: Equatable, Sendable {
    case inProgress
    case confirmed
    case ended
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "IN_PROGRESS": self = .inProgress
        case "CONFIRMED": self = .confirmed
        case "ENDED": self = .ended
        default: self = .unknown(rawValue)
        }
    }
}

public enum GroupLocationStatus: Equatable, Sendable {
    case before
    case confirmed
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "BEFORE": self = .before
        case "CONFIRMED": self = .confirmed
        default: self = .unknown(rawValue)
        }
    }
}

public enum GroupDateVoteStatus: Equatable, Sendable {
    case before
    case completed
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "BEFORE": self = .before
        case "COMPLETED": self = .completed
        default: self = .unknown(rawValue)
        }
    }
}

public enum GroupAttendanceStatus: Equatable, Sendable {
    case join
    case pending
    case leave
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "JOIN": self = .join
        case "PENDING": self = .pending
        case "LEAVE": self = .leave
        default: self = .unknown(rawValue)
        }
    }
}
