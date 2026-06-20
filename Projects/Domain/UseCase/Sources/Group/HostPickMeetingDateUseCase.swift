//
//  HostPickMeetingDateUseCase.swift
//  UseCase
//

public protocol HostPickMeetingDateUseCase: Sendable {
    func execute(meetingId: Int64, date: String) async throws
}
