//
//  UpdateAttendanceUseCase.swift
//  UseCase
//

import Entity

public protocol UpdateAttendanceUseCase: Sendable {
    func execute(groupId: Int, attendanceStatus: AttendanceStatus) async throws
}
