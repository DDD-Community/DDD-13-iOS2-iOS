//
//  GroupDetail.swift
//  Entity
//

import Foundation

public struct GroupDetail: Identifiable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let themeTagCode: String
    public let themeTagDisplay: String
    public let locationStatus: GroupLocationStatus
    public let dateVoteStatus: GroupDateVoteStatus
    public let confirmedDate: String?
    public let members: [GroupDetailMember]

    public var meetingId: Int { id }

    public init(
        id: Int,
        name: String,
        themeTagCode: String,
        themeTagDisplay: String,
        locationStatus: GroupLocationStatus,
        dateVoteStatus: GroupDateVoteStatus,
        confirmedDate: String?,
        members: [GroupDetailMember]
    ) {
        self.id = id
        self.name = name
        self.themeTagCode = themeTagCode
        self.themeTagDisplay = themeTagDisplay
        self.locationStatus = locationStatus
        self.dateVoteStatus = dateVoteStatus
        self.confirmedDate = confirmedDate
        self.members = members
    }
}

public struct GroupDetailMember: Identifiable, Equatable, Sendable {
    public let id: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let isHost: Bool
    public let isMe: Bool
    public let attendanceStatus: AttendanceStatus
    public let departurePlaces: [DeparturePlace]

    public init(
        id: Int,
        nickname: String,
        profileImageUrl: String?,
        isHost: Bool,
        isMe: Bool,
        attendanceStatus: AttendanceStatus,
        departurePlaces: [DeparturePlace]
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.isHost = isHost
        self.isMe = isMe
        self.attendanceStatus = attendanceStatus
        self.departurePlaces = departurePlaces
    }
}
