//
//  UpdateAttendanceUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class UpdateAttendanceUseCaseImpl: UpdateAttendanceUseCase {
    private let repository: GroupRepositoryProtocol

    public init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, attendanceStatus: AttendanceStatus) async throws {
        try await repository.updateAttendance(meetingId: meetingId, attendanceStatus: attendanceStatus)
    }
}
