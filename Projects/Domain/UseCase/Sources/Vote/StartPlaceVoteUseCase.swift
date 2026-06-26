//
//  StartPlaceVoteUseCase.swift
//  UseCase
//

public protocol StartPlaceVoteUseCase: Sendable {
    func execute(meetingId: Int, durationDays: Int) async throws
}
