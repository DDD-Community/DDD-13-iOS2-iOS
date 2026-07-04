//
//  GroupInvitation.swift
//  Entity
//

public struct GroupInvitation: Equatable, Sendable {
    public let inviteLink: String
    public let groupName: String
    public let hostNickname: String

    public init(
        inviteLink: String,
        groupName: String,
        hostNickname: String
    ) {
        self.inviteLink = inviteLink
        self.groupName = groupName
        self.hostNickname = hostNickname
    }
}
