//
//  CreateGroupResult.swift
//  Entity
//

public struct CreateGroupResult: Equatable, Sendable {
    public let groupId: Int
    public let meetingId: Int
    public let name: String
    public let themeTagCode: String

    public init(
        groupId: Int,
        meetingId: Int,
        name: String,
        themeTagCode: String
    ) {
        self.groupId = groupId
        self.meetingId = meetingId
        self.name = name
        self.themeTagCode = themeTagCode
    }
}
