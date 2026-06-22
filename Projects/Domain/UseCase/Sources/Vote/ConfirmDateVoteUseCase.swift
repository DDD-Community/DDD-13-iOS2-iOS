//
//  ConfirmDateVoteUseCase.swift
//  UseCase
//

public protocol ConfirmDateVoteUseCase: Sendable {
    func execute(meetingId: Int, optionId: Int) async throws
}
