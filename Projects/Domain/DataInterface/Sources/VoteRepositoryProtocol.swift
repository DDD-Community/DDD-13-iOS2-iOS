//
//  VoteRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol VoteRepositoryProtocol: Sendable {
    func fetchDateVote(meetingId: Int) async throws -> DateVote
    func fetchPlaceVote(meetingId: Int) async throws -> PlaceVote
    func fetchConfirmedPlaceResult(meetingId: Int) async throws -> ConfirmedPlaceResult
    func startDateVote(meetingId: Int, candidateDates: [String], durationDays: Int) async throws
    func submitDateVote(meetingId: Int, optionIds: [Int]) async throws
    func confirmDateVote(meetingId: Int, optionId: Int) async throws
    func startPlaceVote(meetingId: Int, durationDays: Int) async throws
    func submitPlaceVote(meetingId: Int, placeIds: [Int]) async throws
}
