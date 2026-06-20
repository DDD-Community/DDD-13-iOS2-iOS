//
//  VoteRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol VoteRepositoryProtocol: Sendable {
    func fetchDateVote(meetingId: Int) async throws -> DateVote
    func fetchPlaceVote(meetingId: Int) async throws -> PlaceVote
    func fetchConfirmedPlaceResult(meetingId: Int) async throws -> ConfirmedPlaceResult
    func submitDateVote(meetingId: Int, optionIds: [Int]) async throws
    func confirmDateVote(meetingId: Int, optionId: Int) async throws
    func submitPlaceVote(meetingId: Int, placeIds: [Int]) async throws
}
