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

    public func execute(groupId: Int64, attendanceStatus: AttendanceStatus) async throws {
        try await repository.updateAttendance(groupId: groupId, attendanceStatus: attendanceStatus)
    }
}
