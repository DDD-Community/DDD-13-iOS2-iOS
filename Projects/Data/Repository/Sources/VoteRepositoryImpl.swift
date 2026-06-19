//
//  VoteRepositoryImpl.swift
//  Repository
//

import DataInterface
import Entity
import Model
import API
import Networking

public final class VoteRepositoryImpl: VoteRepositoryProtocol {
    public init() {}

    public func fetchDateVote(meetingId: Int) async throws -> DateVote {
        let response: DateVoteResponseDTO = try await NetworkManager.shared.request(
            VoteEndpoint.fetchDateVote(meetingId: meetingId)
        )
        return response.toEntity()
    }

    public func fetchPlaceVote(meetingId: Int) async throws -> PlaceVote {
        let response: PlaceVoteResponseDTO = try await NetworkManager.shared.request(
            VoteEndpoint.fetchPlaceVote(meetingId: meetingId)
        )
        return response.toEntity()
    }

    public func submitDateVote(meetingId: Int, optionIds: [Int]) async throws {
        let requestDTO = SubmitDateVoteRequestDTO(optionIds: optionIds)
        try await NetworkManager.shared.requestVoid(
            VoteEndpoint.submitDateVote(meetingId: meetingId, requestDTO)
        )
    }

    public func confirmDateVote(meetingId: Int, optionId: Int) async throws {
        let requestDTO = ConfirmDateVoteRequestDTO(optionId: optionId)
        try await NetworkManager.shared.requestVoid(
            VoteEndpoint.confirmDateVote(meetingId: meetingId, requestDTO)
        )
    }
}
