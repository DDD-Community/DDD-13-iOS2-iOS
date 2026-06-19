//
//  CreateGroupResult.swift
//  Entity
//

public struct CreateGroupResult: Equatable, Sendable {
    public let groupId: Int64
    public let meetingId: Int64
    public let name: String
    public let themeTagCode: String

    public init(
        groupId: Int64,
        meetingId: Int64,
        name: String,
        themeTagCode: String
    ) {
        self.groupId = groupId
        self.meetingId = meetingId
        self.name = name
        self.themeTagCode = themeTagCode
    }
}
