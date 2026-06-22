//
//  HostPickMeetingDateUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class HostPickMeetingDateUseCaseImpl: HostPickMeetingDateUseCase {
    private let repository: GroupRepositoryProtocol

    public init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, date: String) async throws {
        try await repository.hostPickMeetingDate(meetingId: meetingId, date: date)
    }
}
