//
//  ConfirmPlaceVoteUseCase.swift
//  UseCase
//

public protocol ConfirmPlaceVoteUseCase: Sendable {
    func execute(meetingId: Int) async throws
}
