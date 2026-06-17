//
//  GroupRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol GroupRepositoryProtocol: Sendable {
    func fetchGroups() async throws -> [Group]
    func createGroup(name: String, themeTagCode: String) async throws -> CreateGroupResult
    func fetchGroupDetail(meetingId: Int64) async throws -> GroupDetail
    func updateAttendance(groupId: Int64, attendanceStatus: AttendanceStatus) async throws
}
