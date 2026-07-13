//
//  UpdateAttendanceUseCase.swift
//  UseCase
//

import Entity

public protocol UpdateAttendanceUseCase: Sendable {
    func execute(meetingId: Int, attendanceStatus: AttendanceStatus) async throws
}
