//
//  HostPickMeetingDateUseCase.swift
//  UseCase
//

public protocol HostPickMeetingDateUseCase: Sendable {
    func execute(meetingId: Int, date: String) async throws
}
