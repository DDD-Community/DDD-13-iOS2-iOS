//
//  VoteRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol VoteRepositoryProtocol: Sendable {
    func fetchDateVote(meetingId: Int) async throws -> DateVote
    func fetchPlaceVote(meetingId: Int) async throws -> PlaceVote
}
