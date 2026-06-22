//
//  SubmitPlaceVoteUseCase.swift
//  UseCase
//

public protocol SubmitPlaceVoteUseCase: Sendable {
    func execute(meetingId: Int, placeIds: [Int]) async throws
}
