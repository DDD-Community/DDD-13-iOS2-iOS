//
//  GroupRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol GroupRepositoryProtocol: Sendable {
    func fetchGroups() async throws -> [Group]
    func createGroup(name: String, themeTagCode: String) async throws -> CreateGroupResult
    func hostPickMeetingDate(meetingId: Int64, date: String) async throws
}
