//
//  StartDateVoteUseCase.swift
//  UseCase
//

public protocol StartDateVoteUseCase: Sendable {
    func execute(meetingId: Int, candidateDates: [String], durationDays: Int) async throws
}
