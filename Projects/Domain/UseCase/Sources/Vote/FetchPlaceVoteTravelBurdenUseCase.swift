//
//  FetchPlaceVoteTravelBurdenUseCase.swift
//  UseCase
//

import Entity

public protocol FetchPlaceVoteTravelBurdenUseCase: Sendable {
    func execute(meetingId: Int, placeId: Int) async throws -> PlaceVoteTravelBurden
}
