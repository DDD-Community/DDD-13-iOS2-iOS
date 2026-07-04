//
//  GroupRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol GroupRepositoryProtocol: Sendable {
    func fetchGroups() async throws -> [Group]
    func createGroup(name: String, themeTagCode: String) async throws -> CreateGroupResult
    func hostPickMeetingDate(meetingId: Int, date: String) async throws
    func fetchGroupDetail(meetingId: Int) async throws -> GroupDetail
    func updateAttendance(meetingId: Int, attendanceStatus: AttendanceStatus) async throws
    func issueInviteCode(groupId: Int) async throws -> String
}
