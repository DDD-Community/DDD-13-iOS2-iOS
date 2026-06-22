//
//  SubmitDateVoteUseCase.swift
//  UseCase
//

public protocol SubmitDateVoteUseCase: Sendable {
    func execute(meetingId: Int, optionIds: [Int]) async throws
}
