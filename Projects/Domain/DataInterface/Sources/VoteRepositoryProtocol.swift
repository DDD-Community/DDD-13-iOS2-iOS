//
//  VoteRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol VoteRepositoryProtocol: Sendable {
    func fetchDateVote(meetingId: Int64) async throws -> DateVote
    func fetchPlaceVote(meetingId: Int64) async throws -> PlaceVote
}
