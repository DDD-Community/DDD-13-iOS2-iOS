//
//  UpdateAttendanceUseCase.swift
//  UseCase
//

import Entity

public protocol UpdateAttendanceUseCase: Sendable {
    func execute(groupId: Int64, attendanceStatus: AttendanceStatus) async throws
}
